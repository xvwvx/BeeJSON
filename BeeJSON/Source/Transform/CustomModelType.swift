//
//  CustomModelType.swift
//  BeeJSON
//
//  Created by snow on 2022/8/9.
//

import Foundation

public protocol _CustomModelType: _Transformable {
    init()
    mutating func mapping(mapper: inout CustomModelMapper)
    mutating func didFinishMapping()
}

extension _CustomModelType {
    public mutating func mapping(mapper: inout CustomModelMapper) {}
    public mutating func didFinishMapping() {}
}

extension _CustomModelType {
    
    static func _transform(from object: Any) -> Self? {
        if let dict = object as? [String: Any] {
            return self._transform(dict: dict) as? Self
        }
        return nil
    }

    static func _transform(dict: [String: Any]) -> _CustomModelType? {
        var value = Self.init()
        _transform(dict: dict, to: &value)
        return value
    }
    
    static func _transform(dict: [String: Any], to value: inout Self) {
        let base = try! withPointer(&value) { $0 }
        defer {
            value.didFinishMapping()
        }
        
        let items = CustomModelTypeCache.shared.getOrCreate(type: Self.self)
        
        items.forEach { item in
            if let rawValue = dict[item.name] {
                let value: Any? = {
                    if let transformer = item.assignmentClosure {
                        return transformer(rawValue)
                    }
                    if let transformableType = item.type as? _Transformable.Type {
                        return transformableType.transform(from: rawValue)
                    }
                    return nil
                }()
                if let value = value {
                    let pointer = base.advanced(by: item.offset)
                    withAnyExtension(item.type).write(value, to: pointer)
                }
            }
        }
    
    }
}

extension _CustomModelType {

    func _plainValue() -> Any? {
        return Self._serialize(self)
    }
    
    static func _serialize(_ object: Self) -> Any? {
        var object = object
        return try! withPointer(&object) { base -> [String: Any] in
            let items = CustomModelTypeCache.shared.getOrCreate(type: Self.self)
            return items.reduce(into: [String: Any]()) { result, item in
                let pointer = base.advanced(by: item.offset)
                let rawValue = withAnyExtension(item.type).value(from: pointer)
                if let value = rawValue as? _Transformable {
                    result[item.name] = value.plainValue()
                }
            }
        }
    }
    
}

