//
//  JSONAny.swift
//  BeeJSON
//  
//  Created  by 张绍平 on 2022/3/21
//  
//  
	

import Foundation

@propertyWrapper
public struct JSONAny<T>: Codable {
    
    public var wrappedValue: T
    
    public init(_ value: T) {
        wrappedValue = value
    }
    
    public func encode(to encoder: Encoder) throws {
        let encoder: Encoder = {
            if let encoder = encoder as? EncoderImpl {
                return encoder.encoder
            }
            return encoder
        }()
        if let encodable = wrappedValue as? Encodable {
            try encodable.encode(to: encoder)
        } else if let value = wrappedValue as? [String: Any] {
            var container = encoder.container(keyedBy: AnyCodingKey.self)
            try container.encode(value)
        } else if let value = wrappedValue as? [Any] {
            var container = encoder.unkeyedContainer()
            try container.encode(value)
        } else {
            var container = encoder.singleValueContainer()
            try container.encodeAny(wrappedValue)
        }
    }
    
    public init(from decoder: Decoder) throws {
        let decoder: Decoder = {
            if let decoder = decoder as? DecoderImpl {
                return decoder.decoder
            }
            return decoder
        }()
        if let decodable = T.self as? Decodable.Type {
            if let value = try decodable.init(from: decoder) as? T {
                wrappedValue = value
                return
            }
        } else if let container = try? decoder.container(keyedBy: AnyCodingKey.self) {
            if let value = try container.decode([String : Any].self) as? T {
                wrappedValue = value
                return
            }
        } else if var container = try? decoder.unkeyedContainer() {
            if let value = try container.decode([Any].self) as? T {
                wrappedValue = value
                return
            }
        } else if let container = try? decoder.singleValueContainer() {
            if let value = try container.decodeAny() as? T {
                wrappedValue = value
                return
            }
        }
        throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: decoder.codingPath, debugDescription: ""))
    }
    
}
