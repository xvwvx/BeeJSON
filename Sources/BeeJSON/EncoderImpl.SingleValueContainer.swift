//
//  EncoderImpl.SingleValueContainer.swift
//  BeeJSON
//  
//  Created  by 张绍平 on 2022/3/21
//  
//  
	

import Foundation

extension EncoderImpl {
    
    struct SingleValueContainer: SingleValueEncodingContainer {
        
        private let impl: EncoderImpl
        private var container: SingleValueEncodingContainer
        
        init(_ impl: EncoderImpl, _ container: SingleValueEncodingContainer) {
            self.impl = impl
            self.container = container
        }
        
        var codingPath: [CodingKey] {
            return container.codingPath
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
            try EncoderImpl.encode(impl.jsonEncoder, encoder: impl, value: value)
        }
        
    }
    
}
