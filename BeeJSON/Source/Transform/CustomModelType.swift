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
    
    static func _transform(from object: Any) throws -> Self? {
        if let dict = object as? [String: Any] {
            return try self._transform(dict: dict) as? Self
        }
        return nil
    }

    static func _transform(dict: [String: Any]) throws -> _CustomModelType? {
        var value = Self.init()
        try value._transform(dict: dict)
        return value
    }
    
    mutating func _transform(dict: [String: Any]) throws {
        let base = try! withPointer(&self) { $0 }
        defer {
            self.didFinishMapping()
        }
        
        let items = try CustomModelTypeCache.shared.getOrCreate(type: Self.self)
        
        for item in items {
            if let rawValue = dict[item.name] {
                let pointer = base.advanced(by: item.offset)
                let any = withAnyExtension(item.type)
                let value: Any? = try {
                    if let transformer = item.transformFrom {
                        return transformer(rawValue)
                    }
                    if let transformableType = item.type as? _CustomModelType.Type {
                        if let dict = rawValue as? [String: Any], !dict.isEmpty {
                            var value = (any.read(pointer: pointer) as? _CustomModelType) ?? transformableType.init()
                            try value._transform(dict: dict)
                            return value
                        }
                        return nil 
                    }
                    if let transformableType = item.type as? _Transformable.Type {
                        return try transformableType.transform(from: rawValue)
                    }
                    return nil
                }()
                if let value = value {
                    any.write(pointer: pointer, value: value)
                }
            }
        }
    }
}

extension _CustomModelType {

    func _plainValue() throws -> Any? {
        return try Self._serialize(self)
    }
    
    static func _serialize(_ object: Self) throws -> Any? {
        var object = object
        return try withPointer(&object) { base -> [String: Any] in
            let items = try CustomModelTypeCache.shared.getOrCreate(type: Self.self)
            return try items.reduce(into: [String: Any]()) { result, item in
                let pointer = base.advanced(by: item.offset)
                let rawValue = withAnyExtension(item.type).read(pointer: pointer)
                if let value = rawValue as? _Transformable {
                    result[item.name] = try value.plainValue()
                }
            }
        }
    }
    
}

