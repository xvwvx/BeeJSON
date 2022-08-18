//
//  Transform.swift
//  BeeJSON
//
//  Created by snow on 2022/8/9.
//

import Foundation

public protocol Transformable: _CustomBasicType {}

public protocol Transform: _CustomModelType {}

public protocol TransformEnum: _RawEnumProtocol {}

public struct Transformer {
    public init() {}
}

public extension Transformer {
    
    static func decode<T>(_ type: T.Type, from data: Data) throws -> T? {
        if let transformableType = type as? _Transformable.Type {
            let object = try JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed)
            return try transformableType.transform(from: object) as? T
        }
        throw TransformError.validDecodeType(type)
    }
    
    static func decode<T>(_ type: T.Type, from string: String) throws -> T? {
        if let data = string.data(using: .utf8) {
            return try decode(type, from: data)
        }
        return nil
    }
    
}

public extension Transformer {
    
    static func encode<T>(_ value: T) throws -> Any? {
        if let transformable = value as? _Transformable {
            return try transformable.plainValue()
        }
        throw TransformError.validEncodeType(type(of: self))
    }
    
    static func encodeToData<T>(_ value: T, options: JSONSerialization.WritingOptions = [.fragmentsAllowed]) throws -> Data? {
        if let value = try encode(value) {
            do {
                return try JSONSerialization.data(withJSONObject: value, options: options)
            } catch {
                throw TransformError.validJSONObject(error)
            }
        }
        return nil
    }
    
    static func encodeToString<T>(_ value: T, options: JSONSerialization.WritingOptions = [.fragmentsAllowed]) throws -> String? {
        if let data = try encodeToData(value, options: options) {
            return String(data: data, encoding: .utf8)
        }
        return nil
    }
    
}
