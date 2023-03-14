//
//  JSONDecoderImpl+SingleValueContainer.swift
//  BeeJSON
//
//  Created by snow on 2022/11/21.
//

import Foundation

extension JSONDecoderImpl {
    
    struct SingleValueContainer: SingleValueDecodingContainer {
        
        let impl: JSONDecoderImpl
        let any: Any?
        let codingPath: [CodingKey]
        let type: Any.Type?
        
        init(impl: JSONDecoderImpl, codingPath: [CodingKey], any: Any?, type: Any.Type?) {
            self.impl = impl
            self.codingPath = codingPath
            self.any = any
            self.type = type
        }
        
        func decodeNil() -> Bool {
            self.any == nil
        }
        
        func decode(_ type: Bool.Type) throws -> Bool {
            try decodeAsType(type)
        }
        
        func decode(_ type: String.Type) throws -> String {
            try decodeAsType(type)
        }
        
        func decode(_ type: Double.Type) throws -> Double {
            try decodeAsType(type)
        }
        
        func decode(_ type: Float.Type) throws -> Float {
            try decodeAsType(type)
        }
        
        func decode(_ type: Int.Type) throws -> Int {
            try decodeAsType(type)
        }
        
        func decode(_ type: Int8.Type) throws -> Int8 {
            try decodeAsType(type)
        }
        
        func decode(_ type: Int16.Type) throws -> Int16 {
            try decodeAsType(type)
        }
        
        func decode(_ type: Int32.Type) throws -> Int32 {
            try decodeAsType(type)
        }
        
        func decode(_ type: Int64.Type) throws -> Int64 {
            try decodeAsType(type)
        }
        
        func decode(_ type: UInt.Type) throws -> UInt {
            try decodeAsType(type)
        }
        
        func decode(_ type: UInt8.Type) throws -> UInt8 {
            try decodeAsType(type)
        }
        
        func decode(_ type: UInt16.Type) throws -> UInt16 {
            try decodeAsType(type)
        }
        
        func decode(_ type: UInt32.Type) throws -> UInt32 {
            try decodeAsType(type)
        }
        
        func decode(_ type: UInt64.Type) throws -> UInt64 {
            try decodeAsType(type)
        }
        
        func decode<T>(_ type: T.Type) throws -> T where T : Decodable {
            try decodeAsType(type)
        }
        
    }
    
}

extension JSONDecoderImpl.SingleValueContainer {
    
    fileprivate func decodeAsType<T>(_ type: T.Type) throws -> T where T : Decodable {
        if let value = self.impl.unwrap(type, value: self.any) as? T {
            return value
        }
        
        throw DecodingError.typeMismatch(
            Dictionary<String, Any>.self,
            DecodingError.Context(
                codingPath: self.codingPath,
                debugDescription: "Expected to decode dictionary but found \(self.any) instead."
            )
        )
    }
    
}
