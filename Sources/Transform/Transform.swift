//
//  Transform.swift
//  BeeJSON
//
//  Created by snow on 2022/8/9.
//

import Foundation

public protocol BeeJSONCustomTransformable: _CustomBasicType {}

public protocol BeeJSON: _CustomModelType {}

public protocol BeeJSONEnum: _RawEnumProtocol {}

public struct Transformer {
    
    public static var ignoreLazy = true
    
}

public extension Transformer {
    
    static func decode<T>(_ type: T.Type, from any: Any) throws -> T? where T: _Transformable {
        return try type.transform(from: any)
    }
    
    static func decode<T>(_ type: T.Type, from data: Data) throws -> T? where T: _Transformable {
        let any = try JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed)
        return try type.transform(from: any)
    }
    
    static func decode<T>(_ type: T.Type, from string: String) throws -> T? where T: _Transformable {
        if let data = string.data(using: .utf8) {
            return try decode(type, from: data)
        }
        return nil
    }
    
}

public extension Transformer {
    
    static func encode<T>(_ value: T) throws -> Any? where T: _Transformable {
        return try value.plainValue()
    }
    
    static func encodeToData<T>(_ value: T, options: JSONSerialization.WritingOptions = [.fragmentsAllowed]) throws -> Data? where T: _Transformable {
        if let value = try encode(value) {
            return try JSONSerialization.data(withJSONObject: value, options: options)
        }
        return nil
    }
    
    static func encodeToString<T>(_ value: T, options: JSONSerialization.WritingOptions = [.fragmentsAllowed]) throws -> String? where T: _Transformable {
        if let data = try encodeToData(value, options: options) {
            return String(data: data, encoding: .utf8)
        }
        return nil
    }
    
}
