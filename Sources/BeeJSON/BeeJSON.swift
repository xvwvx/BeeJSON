//
//  BeeJSON.swift
//  BeeJSON
//
//  Created  by 张绍平 on 2022/3/14
//
//
    

import Foundation


public protocol BeeJSON {
    init()
    static func defaultValues() -> [String: Any]
}

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
        let mirror = Mirror(reflecting: value)
        let dict = mirror.children.reduce(into: [String: Any]()) { result, child in
            if let label = child.label {
                result[label] = child.value
            }
        }
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

