//
//  KeyedEncodingswift
//  BeeJSON
//  
//  Created  by 张绍平 on 2022/3/22
//  
//  
	

import Foundation


public extension KeyedEncodingContainer {
    
    mutating func encode(_ dict: [String: Any]) throws {
        for (key, any) in dict {
            switch any {
            case let encodable as Encodable:
                let encoder = superEncoder(forKey: .init(stringValue: key)!)
                try encodable.encode(to: encoder)
            case let value as [String: Any]:
                var container = nestedContainer(keyedBy: AnyCodingKey.self, forKey: .init(stringValue: key)!)
                try container.encode(value)
            case let value as [Any]:
                var container = nestedUnkeyedContainer(forKey: .init(stringValue: key)!)
                try container.encode(value)
            default:
                break
            }
        }
    }
    
}

public extension UnkeyedEncodingContainer {
    
    mutating func encode(_ array: [Any]) throws {
        for any in array {
            switch any {
            case let encodable as Encodable:
                let encoder = superEncoder()
                try encodable.encode(to: encoder)
            case let value as [String: Any]:
                var container = nestedContainer(keyedBy: AnyCodingKey.self)
                try container.encode(value)
            case let value as [Any]:
                var container = nestedUnkeyedContainer()
                try container.encode(value)
            default:
                break
            }
        }
    }
    
}

public extension SingleValueEncodingContainer {
    
    mutating func encodeAny(_ any: Any) throws {
        switch any {
        case let value as String:
            try encode(value)
        case let value as Int:
            try encode(value)
        case let value as Double:
            try encode(value)
        case let value as Bool:
            try encode(value)
        case let value as UInt64:
            try encode(value)
        default:
            break
        }
    }
    
}
