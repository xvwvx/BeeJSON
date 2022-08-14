//
//  Transformable.swift
//  BeeJSON
//
//  Created by snow on 2022/8/9.
//

public protocol _Transformable {}

extension _Transformable {
    
    static func transform(from object: Any) throws -> Self? {
        if let typedObject = object as? Self {
            return typedObject
        }
        switch self {
        case let type as _CustomBasicType.Type:
            return try type._transform(from: object) as? Self
        case let type as _BuiltInBridgeType.Type:
            return try type._transform(from: object) as? Self
        case let type as _BuiltInBasicType.Type:
            return try type._transform(from: object) as? Self
        case let type as _RawEnumProtocol.Type:
            return type._transform(from: object) as? Self
        case let type as _CustomModelType.Type:
            return try type._transform(from: object) as? Self
        default:
            return nil
        }
    }
    
    func plainValue() throws -> Any? {
        switch self {
        case let rawValue as _CustomBasicType:
            return try rawValue._plainValue()
        case let rawValue as _BuiltInBridgeType:
            return try rawValue._plainValue()
        case let rawValue as _BuiltInBasicType:
            return try rawValue._plainValue()
        case let rawValue as _RawEnumProtocol:
            return rawValue._plainValue()
        case let rawValue as _CustomModelType:
            return try rawValue._plainValue()
        default:
            return nil
        }
    }
    
}
