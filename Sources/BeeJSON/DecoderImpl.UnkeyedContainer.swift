//
//  UnkeyedContainer.swift
//  BeeJSON
//  
//  Created  by 张绍平 on 2022/3/14
//  
//  
	

import Foundation

extension DecoderImpl {
    
    struct UnkeyedContainer: UnkeyedDecodingContainer {
        
        private let impl: DecoderImpl
        private var container: UnkeyedDecodingContainer

        init(_ impl: DecoderImpl, _ container: UnkeyedDecodingContainer) {
            self.impl = impl
            self.container = container
        }
        
        var codingPath: [CodingKey] {
            container.codingPath
        }
        
        var count: Int? {
            container.count
        }
        
        var isAtEnd: Bool {
            container.isAtEnd
        }
        
        var currentIndex: Int {
            container.currentIndex
        }
        
        mutating func decodeNil() throws -> Bool {
            try container.decodeNil()
        }
        
        mutating func decode(_ type: Bool.Type) throws -> Bool {
            try container.decode(type)
        }
        
        mutating func decode(_ type: String.Type) throws -> String {
            try container.decode(type)
        }
        
        mutating func decode(_ type: Double.Type) throws -> Double {
            try container.decode(type)
        }
        
        mutating func decode(_ type: Float.Type) throws -> Float {
            try container.decode(type)
        }
        
        mutating func decode(_ type: Int.Type) throws -> Int {
            try container.decode(type)
        }
        
        mutating func decode(_ type: Int8.Type) throws -> Int8 {
            try container.decode(type)
        }
        
        mutating func decode(_ type: Int16.Type) throws -> Int16 {
            try container.decode(type)
        }
        
        mutating func decode(_ type: Int32.Type) throws -> Int32 {
            try container.decode(type)
        }
        
        mutating func decode(_ type: Int64.Type) throws -> Int64 {
            try container.decode(type)
        }
        
        mutating func decode(_ type: UInt.Type) throws -> UInt {
            try container.decode(type)
        }
        
        mutating func decode(_ type: UInt8.Type) throws -> UInt8 {
            try container.decode(type)
        }
        
        mutating func decode(_ type: UInt16.Type) throws -> UInt16 {
            try container.decode(type)
        }
        
        mutating func decode(_ type: UInt32.Type) throws -> UInt32 {
            try container.decode(type)
        }
        
        mutating func decode(_ type: UInt64.Type) throws -> UInt64 {
            try container.decode(type)
        }
        
        mutating func decode<T>(_ type: T.Type) throws -> T where T : Decodable {
            do {
                let decoder = try container.superDecoder()
                return try DecoderImpl.decode(type, decoder: decoder, jsonDecoder: impl.jsonDecoder)
            } catch {
                return try container.decode(type)
            }
        }
        
        mutating func decodeIfPresent(_ type: Bool.Type) throws -> Bool? {
            try container.decodeIfPresent(type)
        }
        
        mutating func decodeIfPresent(_ type: String.Type) throws -> String? {
            try container.decodeIfPresent(type)
        }
        
        mutating func decodeIfPresent(_ type: Double.Type) throws -> Double? {
            try container.decodeIfPresent(type)
        }
        
        mutating func decodeIfPresent(_ type: Float.Type) throws -> Float? {
            try container.decodeIfPresent(type)
        }
        
        mutating func decodeIfPresent(_ type: Int.Type) throws -> Int? {
            try container.decodeIfPresent(type)
        }
        
        mutating func decodeIfPresent(_ type: Int8.Type) throws -> Int8? {
            try container.decodeIfPresent(type)
        }
        
        mutating func decodeIfPresent(_ type: Int16.Type) throws -> Int16? {
            try container.decodeIfPresent(type)
        }
        
        mutating func decodeIfPresent(_ type: Int32.Type) throws -> Int32? {
            try container.decodeIfPresent(type)
        }
        
        mutating func decodeIfPresent(_ type: Int64.Type) throws -> Int64? {
            try container.decodeIfPresent(type)
        }
        
        mutating func decodeIfPresent(_ type: UInt.Type) throws -> UInt? {
            try container.decodeIfPresent(type)
        }
        
        mutating func decodeIfPresent(_ type: UInt8.Type) throws -> UInt8? {
            try container.decodeIfPresent(type)
        }
        
        mutating func decodeIfPresent(_ type: UInt16.Type) throws -> UInt16? {
            try container.decodeIfPresent(type)
        }
        
        mutating func decodeIfPresent(_ type: UInt32.Type) throws -> UInt32? {
            try container.decodeIfPresent(type)
        }
        
        mutating func decodeIfPresent(_ type: UInt64.Type) throws -> UInt64? {
            try container.decodeIfPresent(type)
        }
        
        mutating func decodeIfPresent<T>(_ type: T.Type) throws -> T? where T : Decodable {
            try container.decodeIfPresent(type)
        }
        
        mutating func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type) throws -> KeyedDecodingContainer<NestedKey> where NestedKey : CodingKey {
            let container = try container.nestedContainer(keyedBy: type)
            return KeyedDecodingContainer(KeyedContainer<NestedKey>(impl, container))
        }
        
        mutating func nestedUnkeyedContainer() throws -> UnkeyedDecodingContainer {
            let container = try container.nestedUnkeyedContainer()
            return UnkeyedContainer(impl, container)
        }
        
        mutating func superDecoder() throws -> Decoder {
            let decoder = try container.superDecoder()
            return DecoderImpl(impl.jsonDecoder, decoder: decoder)
        }

    }
    
}

extension DecoderImpl.UnkeyedContainer {
    
    fileprivate mutating func decodeAsType<T>(_ type: T.Type) throws -> T where T : Decodable {
        do {
            let value = try container.decode(type)
            return value
        } catch {
            let value: Any? = {
                if let value = try? container.decode(String.self) {
                    return value
                }
                if let value = try? container.decode(Int.self) {
                    return value
                }
                if let value = try? container.decode(UInt64.self) {
                    return value
                }
                if let value = try? container.decode(Double.self) {
                    return value
                }
                if let value = try? container.decode(Bool.self) {
                    return value
                }
                return nil
            }()
            if let value = impl.unwrap(type, value: value) {
                return value
            }
            throw error
        }
    }
    
}
