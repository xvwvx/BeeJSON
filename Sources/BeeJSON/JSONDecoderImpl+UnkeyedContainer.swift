//
//  JSONDecoderImpl+UnkeyedContainer.swift
//  BeeJSON
//
//  Created by snow on 2022/11/21.
//

import Foundation

extension JSONDecoderImpl {
    
    struct UnkeyedContainer: UnkeyedDecodingContainer {
        
        let impl: JSONDecoderImpl
        let codingPath: [CodingKey]
        let array: [Any]
        
        var count: Int? { self.array.count }
        var isAtEnd: Bool { self.currentIndex >= (self.count ?? 0) }
        var currentIndex = 0
        
        init(impl: JSONDecoderImpl, codingPath: [CodingKey], array: [Any]) {
            self.impl = impl
            self.codingPath = codingPath
            self.array = array
        }
        
        mutating func decodeNil() throws -> Bool {
            if try self.getNextValue(ofType: Any.self) == nil {
                self.currentIndex += 1
                return true
            }
            return false
        }
        
        mutating func decode(_ type: Bool.Type) throws -> Bool {
            try decodeAsType(type)
        }
        
        mutating func decode(_ type: String.Type) throws -> String {
            try decodeAsType(type)
        }
        
        mutating func decode(_ type: Double.Type) throws -> Double {
            try decodeAsType(type)
        }
        
        mutating func decode(_ type: Float.Type) throws -> Float {
            try decodeAsType(type)
        }
        
        mutating func decode(_ type: Int.Type) throws -> Int {
            try decodeAsType(type)
        }
        
        mutating func decode(_ type: Int8.Type) throws -> Int8 {
            try decodeAsType(type)
        }
        
        mutating func decode(_ type: Int16.Type) throws -> Int16 {
            try decodeAsType(type)
        }
        
        mutating func decode(_ type: Int32.Type) throws -> Int32 {
            try decodeAsType(type)
        }
        
        mutating func decode(_ type: Int64.Type) throws -> Int64 {
            try decodeAsType(type)
        }
        
        mutating func decode(_ type: UInt.Type) throws -> UInt {
            try decodeAsType(type)
        }
        
        mutating func decode(_ type: UInt8.Type) throws -> UInt8 {
            try decodeAsType(type)
        }
        
        mutating func decode(_ type: UInt16.Type) throws -> UInt16 {
            try decodeAsType(type)
        }
        
        mutating func decode(_ type: UInt32.Type) throws -> UInt32 {
            try decodeAsType(type)
        }
        
        mutating func decode(_ type: UInt64.Type) throws -> UInt64 {
            try decodeAsType(type)
        }
        
        mutating func decode<T>(_ type: T.Type) throws -> T where T : Decodable {
            let newDecoder = try decoderForNextElement(ofType: T.self)
            let result = try newDecoder.unwrap(as: T.self)
            self.currentIndex += 1
            return result
        }
        
//        mutating func decodeIfPresent(_ type: Bool.Type) throws -> Bool? {
//            fatalError()
//        }
//
//        mutating func decodeIfPresent(_ type: String.Type) throws -> String? {
//            fatalError()
//        }
//
//        mutating func decodeIfPresent(_ type: Double.Type) throws -> Double? {
//            fatalError()
//        }
//
//        mutating func decodeIfPresent(_ type: Float.Type) throws -> Float? {
//            fatalError()
//        }
//
//        mutating func decodeIfPresent(_ type: Int.Type) throws -> Int? {
//            fatalError()
//        }
//
//        mutating func decodeIfPresent(_ type: Int8.Type) throws -> Int8? {
//            fatalError()
//        }
//
//        mutating func decodeIfPresent(_ type: Int16.Type) throws -> Int16? {
//            fatalError()
//        }
//
//        mutating func decodeIfPresent(_ type: Int32.Type) throws -> Int32? {
//            fatalError()
//        }
//
//        mutating func decodeIfPresent(_ type: Int64.Type) throws -> Int64? {
//            fatalError()
//        }
//
//        mutating func decodeIfPresent(_ type: UInt.Type) throws -> UInt? {
//            fatalError()
//        }
//
//        mutating func decodeIfPresent(_ type: UInt8.Type) throws -> UInt8? {
//            fatalError()
//        }
//
//        mutating func decodeIfPresent(_ type: UInt16.Type) throws -> UInt16? {
//            fatalError()
//        }
//
//        mutating func decodeIfPresent(_ type: UInt32.Type) throws -> UInt32? {
//            fatalError()
//        }
//
//        mutating func decodeIfPresent(_ type: UInt64.Type) throws -> UInt64? {
//            fatalError()
//        }
//
//        mutating func decodeIfPresent<T>(_ type: T.Type) throws -> T? where T : Decodable {
//            fatalError()
//        }
        
        mutating func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type) throws -> KeyedDecodingContainer<NestedKey> where NestedKey : CodingKey {
            let decoder = try decoderForNextElement(ofType: KeyedDecodingContainer<NestedKey>.self)
            let container = try decoder.container(keyedBy: type)

            self.currentIndex += 1
            return container
        }
        
        mutating func nestedUnkeyedContainer() throws -> UnkeyedDecodingContainer {
            let decoder = try decoderForNextElement(ofType: UnkeyedDecodingContainer.self)
            let container = try decoder.unkeyedContainer()

            self.currentIndex += 1
            return container
        }
        
        mutating func superDecoder() throws -> Decoder {
            let decoder = try decoderForNextElement(ofType: Decoder.self)
            self.currentIndex += 1
            return decoder
        }
        
        // MARK: -
        
        @inline(__always)
        private func getNextValue<T>(ofType: T.Type) throws -> Any {
            guard !self.isAtEnd else {
                var message = "Unkeyed container is at end."
                if T.self == UnkeyedContainer.self {
                    message = "Cannot get nested unkeyed container -- unkeyed container is at end."
                }
                if T.self == Decoder.self {
                    message = "Cannot get superDecoder() -- unkeyed container is at end."
                }
                
                var path = self.codingPath
                path.append(AnyCodingKey(intValue: self.currentIndex))
                
                throw DecodingError.valueNotFound(
                    T.self,
                    .init(codingPath: path,
                          debugDescription: message,
                          underlyingError: nil))
            }
            return self.array[self.currentIndex]
        }
        
        private mutating func decoderForNextElement<T>(ofType: T.Type) throws -> JSONDecoderImpl {
            let value = try self.getNextValue(ofType: T.self)
            let newPath = self.codingPath + [AnyCodingKey(intValue: self.currentIndex)]

            return JSONDecoderImpl(
                userInfo: self.impl.userInfo,
                from: value,
                codingPath: newPath,
                options: self.impl.options,
                type: ofType
            )
        }
        
    }
    
}

extension JSONDecoderImpl.UnkeyedContainer {
    
    fileprivate mutating func decodeAsType<T>(_ type: T.Type) throws -> T where T : Decodable {
        let value = try self.getNextValue(ofType: type)
        if let value = self.impl.unwrap(type, value: value) as? T {
            self.currentIndex += 1
            return value
        }
        
        throw DecodingError.typeMismatch(
            Dictionary<String, Any>.self,
            DecodingError.Context(
                codingPath: self.codingPath,
                debugDescription: "Expected to decode dictionary but found \(value) instead."
            )
        )
    }
    
}
