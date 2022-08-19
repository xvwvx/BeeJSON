//
//  BeeJSON.swift
//  BeeJSON
//
//  Created  by 张绍平 on 2022/3/14
//
//
    

import Foundation

public extension BeeJSON {
    
    static func defaultValues() -> [String: Any] {
        if let dict = Cache.shared.get(type: self) {
            return dict
        }
        
        let value: Self
        if let nsType = Self.self as? NSObject.Type {
            value = nsType.createInstance() as! Self
        } else {
            value = Self.init()
        }
        
        func allValues(mirror: Mirror, all: [String: Any] = [:]) -> [String: Any] {
            var all = all
            mirror.children.forEach { child in
                if let label = child.label {
                    all[label] = child.value
                }
            }
            guard let mirror = mirror.superclassMirror else {
                return all
            }
            return allValues(mirror: mirror, all: all)
        }
        let mirror = Mirror(reflecting: value)
        let dict = allValues(mirror: mirror)
        Cache.shared.set(type: self, value: dict)
        return dict
    }
    
}

// this's a workaround before https://bugs.swift.org/browse/SR-5223 fixed
extension NSObject {
    static func createInstance() -> NSObject {
        return self.init()
    }
}

