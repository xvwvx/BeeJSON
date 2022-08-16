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
    
    func decode<T>(_ type: T.Type, from string: String) throws -> T?  {
        if let data = string.data(using: .utf8) {
            return try decode(type, from: data)
        }
        return nil
    }
    
    func decode<T>(_ type: T.Type, from data: Data) throws -> T?  {
        if let transformableType = type as? _Transformable.Type {
            let object = try JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed)
            return try transformableType.transform(from: object) as? T
        }
        return nil
    }
    
}

public extension Transformer {
    
    func encode<T>(_ value: T) throws -> Any? {
        if let transformable = value as? _Transformable {
            return try transformable.plainValue()
        }
        return nil
    }
    
    func encodeToData<T>(_ value: T, options opt: JSONSerialization.WritingOptions = [.fragmentsAllowed]) throws -> Data? {
        if let value = try encode(value) {
            if JSONSerialization.isValidJSONObject(value) {
                return try JSONSerialization.data(withJSONObject: value, options: opt)
            }
        }
        return nil
    }
    
    func encodeToString<T>(_ value: T, options opt: JSONSerialization.WritingOptions = [.fragmentsAllowed]) throws -> String? {
        if let data = try encodeToData(value, options: opt) {
            return String(data: data, encoding: .utf8)
        }
        return nil
    }
    
}
