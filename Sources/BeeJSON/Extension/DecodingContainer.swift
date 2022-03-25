//
//  Decodingswift
//  BeeJSON
//  
//  Created  by 张绍平 on 2022/3/22
//  
//  
	

import Foundation

extension KeyedDecodingContainer {
    
    func decode(_ type: [String: Any].Type) throws -> [String: Any] {
        var dict: [String: Any] = [:]
        for key in allKeys {
            if let value = try? decode(String.self, forKey: key) {
                dict[key.stringValue] = value
            } else if let value = try? decode(Int.self, forKey: key) {
                dict[key.stringValue] = value
            }  else if let value = try? decode(Double.self, forKey: key) {
                dict[key.stringValue] = value
            } else if let value = try? decode(Bool.self, forKey: key) {
                dict[key.stringValue] = value
            } else if let container = try? nestedContainer(keyedBy: AnyCodingKey.self, forKey: key) {
                dict[key.stringValue] = try container.decode([String: Any].self)
            } else if var container = try? nestedUnkeyedContainer(forKey: key) {
                dict[key.stringValue] = try container.decode([Any].self)
            }
        }
        return dict
    }
    
}

extension UnkeyedDecodingContainer {
    
    mutating func decode(_ type: [Any].Type) throws -> [Any] {
        var array: [Any] = []
        while !isAtEnd {
            if let value = try? decode(String.self) {
                array.append(value)
            } else if let value = try? decode(Int.self) {
                array.append(value)
            } else if let value = try? decode(Double.self) {
                array.append(value)
            } else if let value = try? decode(Bool.self) {
                array.append(value)
            } else if let container = try? nestedContainer(keyedBy: AnyCodingKey.self) {
                let value = try container.decode([String: Any].self)
                array.append(value)
            } else if var container = try? nestedUnkeyedContainer() {
                let value = try container.decode([Any].self)
                array.append(value)
            }
        }
        return array
    }
    
}

extension SingleValueDecodingContainer {
    
    func decodeAny() throws -> Any {
        if let value = try? decode(String.self) {
            return value
        }
        if let value = try? decode(Int.self) {
            return value
        }
        if let value = try? decode(Double.self) {
            return value
        }
        if let value = try? decode(Bool.self) {
            return value
        }
        if let value = try? decode(UInt64.self) {
            return value
        }
        throw DecodingError.valueNotFound(Any.self, DecodingError.Context(codingPath: codingPath, debugDescription: "", underlyingError: nil))
    }
}
