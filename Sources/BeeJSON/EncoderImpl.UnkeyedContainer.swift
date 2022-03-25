//
//  EncoderImpl.UnkeyedContainer.swift
//  BeeJSON
//  
//  Created  by 张绍平 on 2022/3/21
//  
//  
	

import Foundation

extension EncoderImpl {
    
    struct UnkeyedContainer: UnkeyedEncodingContainer {
        
        
        private let impl: EncoderImpl
        private var container: UnkeyedEncodingContainer
        
        init(_ impl: EncoderImpl, _ container: UnkeyedEncodingContainer) {
            self.impl = impl
            self.container = container
        }
        
        var codingPath: [CodingKey] {
            container.codingPath
        }
        
        var count: Int {
            container.count
        }
        
        mutating func encodeNil() throws {
            try container.encodeNil()
        }
        
        mutating func encode(_ value: Bool) throws {
            try container.encode(value)
        }
        
        mutating func encode(_ value: String) throws {
            try container.encode(value)
        }
        
        mutating func encode(_ value: Double) throws {
            try container.encode(value)
        }
        
        mutating func encode(_ value: Float) throws {
            try container.encode(value)
        }
        
        mutating func encode(_ value: Int) throws {
            try container.encode(value)
        }
        
        mutating func encode(_ value: Int8) throws {
            try container.encode(value)
        }
        
        mutating func encode(_ value: Int16) throws {
            try container.encode(value)
        }
        
        mutating func encode(_ value: Int32) throws {
            try container.encode(value)
        }
        
        mutating func encode(_ value: Int64) throws {
            try container.encode(value)
        }
        
        mutating func encode(_ value: UInt) throws {
            try container.encode(value)
        }
        
        mutating func encode(_ value: UInt8) throws {
            try container.encode(value)
        }
        
        mutating func encode(_ value: UInt16) throws {
            try container.encode(value)
        }
        
        mutating func encode(_ value: UInt32) throws {
            try container.encode(value)
        }
        
        mutating func encode(_ value: UInt64) throws {
            try container.encode(value)
        }
        
        mutating func encode<T>(_ value: T) throws where T : Encodable {
            let encoder = container.superEncoder()
            try EncoderImpl.encode(impl.jsonEncoder, encoder: encoder, value: value)
        }
        
        mutating func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type) -> KeyedEncodingContainer<NestedKey> where NestedKey : CodingKey {
            let container = container.nestedContainer(keyedBy: keyType)
            return KeyedEncodingContainer(KeyedContainer<NestedKey>(impl, container))
        }
        
        mutating func nestedUnkeyedContainer() -> UnkeyedEncodingContainer {
            let container = container.nestedUnkeyedContainer()
            return UnkeyedContainer(impl, container)
        }
        
        mutating func superEncoder() -> Encoder {
            let encoder = container.superEncoder()
            return EncoderImpl(impl.jsonEncoder, encoder: encoder)
        }
        
    }
    
}
