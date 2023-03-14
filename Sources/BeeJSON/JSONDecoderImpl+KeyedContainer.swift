//
//  JSONDecoderImpl+KeyedContainer.swift
//  BeeJSON
//
//  Created by snow on 2022/11/21.
//

import Foundation

extension JSONDecoderImpl {
    
    struct KeyedContainer<Key>: KeyedDecodingContainerProtocol where Key : CodingKey {
        
        let impl: JSONDecoderImpl
        let codingPath: [CodingKey]
        let dictionary: [String: Any]
        
        init(impl: JSONDecoderImpl, codingPath: [CodingKey], dictionary: [String: Any]) {
            self.impl = impl
            self.codingPath = codingPath
            self.dictionary = dictionary
        }
        
        var allKeys: [Key] {
            self.dictionary.keys.compactMap { Key(stringValue: $0) }
        }
        
        func contains(_ key: Key) -> Bool {
            return self.dictionary[key.stringValue] != nil
        }
        
        func decodeNil(forKey key: Key) throws -> Bool {
            return self.dictionary[key.stringValue] == nil
        }
        
        func decode(_ type: Bool.Type, forKey key: Key) throws -> Bool {
            try decodeAsType(type, forKey: key)
        }
        
        func decode(_ type: String.Type, forKey key: Key) throws -> String {
            try decodeAsType(type, forKey: key)
        }
        
        func decode(_ type: Double.Type, forKey key: Key) throws -> Double {
            try decodeAsType(type, forKey: key)
        }
        
        func decode(_ type: Float.Type, forKey key: Key) throws -> Float {
            try decodeAsType(type, forKey: key)
        }
        
        func decode(_ type: Int.Type, forKey key: Key) throws -> Int {
            try decodeAsType(type, forKey: key)
        }
        
        func decode(_ type: Int8.Type, forKey key: Key) throws -> Int8 {
            try decodeAsType(type, forKey: key)
        }
        
        func decode(_ type: Int16.Type, forKey key: Key) throws -> Int16 {
            try decodeAsType(type, forKey: key)
        }
        
        func decode(_ type: Int32.Type, forKey key: Key) throws -> Int32 {
            try decodeAsType(type, forKey: key)
        }
        
        func decode(_ type: Int64.Type, forKey key: Key) throws -> Int64 {
            try decodeAsType(type, forKey: key)
        }
        
        func decode(_ type: UInt.Type, forKey key: Key) throws -> UInt {
            try decodeAsType(type, forKey: key)
        }
        
        func decode(_ type: UInt8.Type, forKey key: Key) throws -> UInt8 {
            try decodeAsType(type, forKey: key)
        }
        
        func decode(_ type: UInt16.Type, forKey key: Key) throws -> UInt16 {
            try decodeAsType(type, forKey: key)
        }
        
        func decode(_ type: UInt32.Type, forKey key: Key) throws -> UInt32 {
            try decodeAsType(type, forKey: key)
        }
        
        func decode(_ type: UInt64.Type, forKey key: Key) throws -> UInt64 {
            try decodeAsType(type, forKey: key)
        }
        
        func decode<T>(_ type: T.Type, forKey key: Key) throws -> T where T : Decodable {
            let newDecoder = try decoderForKey(key, type: type)
            return try newDecoder.unwrap(as: T.self)
        }
        
        func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type, forKey key: Key) throws -> KeyedDecodingContainer<NestedKey> where NestedKey : CodingKey {
            try decoderForKey(key, type: type).container(keyedBy: type)
        }
        
        func nestedUnkeyedContainer(forKey key: Key) throws -> UnkeyedDecodingContainer {
            try decoderForKey(key, type: Any.self).unkeyedContainer()
        }
        
        func superDecoder() throws -> Decoder {
            return decoderForKeyNoThrow(AnyCodingKey.super)
        }
        
        func superDecoder(forKey key: Key) throws -> Decoder {
            return decoderForKeyNoThrow(key)
        }
        
        // MARK: -
        
        @inline(__always) private func getValue<LocalKey: CodingKey>(forKey key: LocalKey) throws -> Any {
            guard let value = dictionary[key.stringValue] else {
                throw DecodingError.keyNotFound(key, .init(
                    codingPath: self.codingPath,
                    debugDescription: "No value associated with key \(key) (\"\(key.stringValue)\")."
                ))
            }
            return value
        }
        
        private func decoderForKey<LocalKey: CodingKey, T>(_ key: LocalKey, type: T.Type? = nil) throws -> JSONDecoderImpl {
            let value = try getValue(forKey: key)
            var newPath = self.codingPath
            newPath.append(key)
            
            return JSONDecoderImpl(
                userInfo: self.impl.userInfo,
                from: value,
                codingPath: newPath,
                options: self.impl.options,
                type: type
            )
        }
        
        private func decoderForKeyNoThrow<LocalKey: CodingKey>(_ key: LocalKey) -> JSONDecoderImpl {
            let value = try? getValue(forKey: key)
            var newPath = self.codingPath
            newPath.append(key)
            
            return JSONDecoderImpl(
                userInfo: self.impl.userInfo,
                from: value,
                codingPath: newPath,
                options: self.impl.options,
                type: nil
            )
        }
        
    }
    
}

extension JSONDecoderImpl.KeyedContainer {
    
    fileprivate func decodeAsType<T>(_ type: T.Type, forKey key: Key) throws -> T where T : Decodable {
        let value = self.dictionary[key.stringValue]
        if let value = self.impl.unwrap(type, value: value) as? T {
            return value
        }
        
        throw DecodingError.dataCorrupted(.init(
            codingPath: self.codingPath,
            debugDescription: "Parsed JSON <\(value)> does not fit in \(type)."))
    }
    
}

