//
//  EncoderImpl.KeyedContainer.swift
//  BeeJSON
//  
//  Created  by 张绍平 on 2022/3/21
//  
//  
	

import Foundation

extension EncoderImpl {
    
    public struct KeyedContainer<Key> : KeyedEncodingContainerProtocol where Key : CodingKey {
        
        private let impl: EncoderImpl
        private var container: KeyedEncodingContainer<Key>
        
        init(_ impl: EncoderImpl, _ container: KeyedEncodingContainer<Key>) {
            self.impl = impl
            self.container = container
        }
        
        public var codingPath: [CodingKey] {
            return container.codingPath
        }
        
        public mutating func encodeNil(forKey key: Key) throws {
            try container.encodeNil(forKey: key)
        }
        
        public mutating func encode(_ value: Bool, forKey key: Key) throws {
            try container.encode(value, forKey: key)
        }
        
        public mutating func encode(_ value: String, forKey key: Key) throws {
            try container.encode(value, forKey: key)
        }
        
        public mutating func encode(_ value: Double, forKey key: Key) throws {
            try container.encode(value, forKey: key)
        }
        
        public mutating func encode(_ value: Float, forKey key: Key) throws {
            try container.encode(value, forKey: key)
        }
        
        public mutating func encode(_ value: Int, forKey key: Key) throws {
            try container.encode(value, forKey: key)
        }
        
        public mutating func encode(_ value: Int8, forKey key: Key) throws {
            try container.encode(value, forKey: key)
        }
        
        public mutating func encode(_ value: Int16, forKey key: Key) throws {
            try container.encode(value, forKey: key)
        }
        
        public mutating func encode(_ value: Int32, forKey key: Key) throws {
            try container.encode(value, forKey: key)
        }
        
        public mutating func encode(_ value: Int64, forKey key: Key) throws {
            try container.encode(value, forKey: key)
        }
        
        public mutating func encode(_ value: UInt, forKey key: Key) throws {
            try container.encode(value, forKey: key)
        }
        
        public mutating func encode(_ value: UInt8, forKey key: Key) throws {
            try container.encode(value, forKey: key)
        }
        
        public mutating func encode(_ value: UInt16, forKey key: Key) throws {
            try container.encode(value, forKey: key)
        }
        
        public mutating func encode(_ value: UInt32, forKey key: Key) throws {
            try container.encode(value, forKey: key)
        }
        
        public mutating func encode(_ value: UInt64, forKey key: Key) throws {
            try container.encode(value, forKey: key)
        }
        
        public mutating func encode<T>(_ value: T, forKey key: Key) throws where T : Encodable {
            let encoder = container.superEncoder(forKey: key)
            try EncoderImpl.encode(impl.jsonEncoder, encoder: encoder, value: value)
        }
        
        public mutating func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type, forKey key: Key) -> KeyedEncodingContainer<NestedKey> where NestedKey : CodingKey {
            let container = container.nestedContainer(keyedBy: keyType, forKey: key)
            return KeyedEncodingContainer(KeyedContainer<NestedKey>(impl, container))
        }
        
        public mutating func nestedUnkeyedContainer(forKey key: Key) -> UnkeyedEncodingContainer {
            let container = container.nestedUnkeyedContainer(forKey: key)
            return UnkeyedContainer(impl, container)
        }
        
        public mutating func superEncoder() -> Encoder {
            let encoder = container.superEncoder()
            return EncoderImpl(impl.jsonEncoder, encoder: encoder)
        }
        
        public mutating func superEncoder(forKey key: Key) -> Encoder {
            let encoder = container.superEncoder(forKey: key)
            return EncoderImpl(impl.jsonEncoder, encoder: encoder)
        }
        
    }
    
}
