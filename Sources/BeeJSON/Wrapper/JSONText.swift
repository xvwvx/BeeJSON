//
//  JSONText.swift
//  BeeJSON
//  
//  Created  by 张绍平 on 2022/3/21
//  
//  
	

import Foundation

@propertyWrapper
public struct JSONText<T>: Codable where T: Codable {
    
    public var wrappedValue: T
    
    public init(_ value: T) {
        wrappedValue = value
    }
    
    public func encode(to encoder: Encoder) throws {
        let jsonEncoder: JSONEncoder = {
            if let encoder = encoder as? EncoderImpl {
                return encoder.jsonEncoder
            }
            return BeeJSONEncoder()
        }()
        let data = try jsonEncoder.encode(wrappedValue)
        let str = String(data: data, encoding: .utf8)!
        var container = encoder.singleValueContainer()
        try container.encode(str)
    }
    
    public init(from decoder: Decoder) throws {
        let str: String = {
            if let container = try? decoder.singleValueContainer(),
               let str = try? container.decode(String.self),
               str != "" {
                return str
            }
            return "{}"
        }()
        let data = str.data(using: .utf8)!
        
        let jsonDecoder: JSONDecoder = {
            if let decoder = decoder as? DecoderImpl {
                return decoder.jsonDecoder
            }
            return BeeJSONDecoder()
        }()
        wrappedValue = try jsonDecoder.decode(T.self, from: data)
    }
    
}
