//
//  KeyedContainer.swift
//  BeeJSON
//  
//  Created  by 张绍平 on 2022/3/14
//  
//  
	

import Foundation

extension DecoderImpl {
    
    struct KeyedContainer<Key> : KeyedDecodingContainerProtocol where Key : CodingKey {
        
        private let impl: DecoderImpl
        
        private let container: KeyedDecodingContainer<Key>
        
        init(_ impl: DecoderImpl, _ container: KeyedDecodingContainer<Key>) {
            self.impl = impl
            self.container = container
        }
        
        public var codingPath: [CodingKey] {
            container.codingPath
        }
        
        public var allKeys: [Key] {
            container.allKeys
        }
        
        public func contains(_ key: Key) -> Bool {
            container.contains(key)
        }
        
        public func decodeNil(forKey key: Key) throws -> Bool {
            try container.decodeNil(forKey: key)
        }
        
        public func decode(_ type: Bool.Type, forKey key: Key) throws -> Bool {
            try decodeAsType(type, forKey: key)
        }
        
        public func decode(_ type: String.Type, forKey key: Key) throws -> String {
            try decodeAsType(type, forKey: key)
        }
        
        public func decode(_ type: Double.Type, forKey key: Key) throws -> Double {
            try decodeAsType(type, forKey: key)
        }
        
        public func decode(_ type: Float.Type, forKey key: Key) throws -> Float {
            try decodeAsType(type, forKey: key)
        }
        
        public func decode(_ type: Int.Type, forKey key: Key) throws -> Int {
            try decodeAsType(type, forKey: key)
        }
        
        public func decode(_ type: Int8.Type, forKey key: Key) throws -> Int8 {
            try decodeAsType(type, forKey: key)
        }
        
        public func decode(_ type: Int16.Type, forKey key: Key) throws -> Int16 {
            try decodeAsType(type, forKey: key)
        }
        
        public func decode(_ type: Int32.Type, forKey key: Key) throws -> Int32 {
            try decodeAsType(type, forKey: key)
        }
        
        public func decode(_ type: Int64.Type, forKey key: Key) throws -> Int64 {
            try decodeAsType(type, forKey: key)
        }
        
        public func decode(_ type: UInt.Type, forKey key: Key) throws -> UInt {
            try decodeAsType(type, forKey: key)
        }
        
        public func decode(_ type: UInt8.Type, forKey key: Key) throws -> UInt8 {
            try decodeAsType(type, forKey: key)
        }
        
        public func decode(_ type: UInt16.Type, forKey key: Key) throws -> UInt16 {
            try decodeAsType(type, forKey: key)
        }
        
        public func decode(_ type: UInt32.Type, forKey key: Key) throws -> UInt32 {
            try decodeAsType(type, forKey: key)
        }
        
        public func decode(_ type: UInt64.Type, forKey key: Key) throws -> UInt64 {
            try decodeAsType(type, forKey: key)
        }
        
        public func decode<T>(_ type: T.Type, forKey key: Key) throws -> T where T : Decodable {
            do {
                let decoder = try container.superDecoder(forKey: key)
                return try DecoderImpl.decode(type, decoder: decoder, jsonDecoder: impl.jsonDecoder)
            } catch {
                return try decodeAsType(type, forKey: key)
            }
        }
        
        public func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type, forKey key: Key) throws -> KeyedDecodingContainer<NestedKey> where NestedKey : CodingKey {
            let container = try container.nestedContainer(keyedBy: type, forKey: key)
            return KeyedDecodingContainer(KeyedContainer<NestedKey>(impl, container))
        }
        
        public func nestedUnkeyedContainer(forKey key: Key) throws -> UnkeyedDecodingContainer {
            let container = try container.nestedUnkeyedContainer(forKey: key)
            return UnkeyedContainer(impl, container)
        }
        
        public func superDecoder() throws -> Decoder {
            let decoder = try container.superDecoder()
            return DecoderImpl(impl.jsonDecoder, decoder: decoder)
        }
        
        public func superDecoder(forKey key: Key) throws -> Decoder {
            let decoder = try container.superDecoder(forKey: key)
            return DecoderImpl(impl.jsonDecoder, decoder: decoder)
        }
        
    }
}

extension DecoderImpl.KeyedContainer {
    
    fileprivate func decodeAsType<T>(_ type: T.Type, forKey key: Key) throws -> T where T : Decodable {
        do {
            let value = try container.decode(type, forKey: key)
            return value
        } catch {
            let value: Any? = {
                if let value = try? container.decode(String.self, forKey: key) {
                    return value
                }
                if let value = try? container.decode(Int.self, forKey: key) {
                    return value
                }
                if let value = try? container.decode(UInt64.self, forKey: key) {
                    return value
                }
                if let value = try? container.decode(Double.self, forKey: key) {
                    return value
                }
                if let value = try? container.decode(Bool.self, forKey: key) {
                    return value
                }
                return nil
            }()
            if let value = impl.unwrap(type, forKey: key, value: value) {
                return value
            }
            throw error
        }
    }
    
}
