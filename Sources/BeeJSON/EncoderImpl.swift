//
//  EncoderImpl.swift
//  BeeJSON
//  
//  Created  by 张绍平 on 2022/3/21
//  
//  
	

import Foundation
import UIKit

public class BeeJSONEncoder: JSONEncoder {
    
    private struct Proxy<T>: Encodable where T: Encodable {
        
        let jsonEncoder: JSONEncoder
        let value: T
        
        init(_ jsonEncoder: JSONEncoder, value: T) {
            self.jsonEncoder = jsonEncoder
            self.value = value
        }
        
        func encode(to encoder: Encoder) throws {
            try EncoderImpl.encode(jsonEncoder, encoder: encoder, value: value)
        }
    }
    
    public override func encode<T>(_ value: T) throws -> Data where T : Encodable {
        let proxy = Proxy(self, value: value)
        return try super.encode(proxy)
    }
}

struct EncoderImpl {
    
    let jsonEncoder: JSONEncoder
    let encoder: Encoder
    
    init(_ jsonEncoder: JSONEncoder, encoder: Encoder, type: Any.Type? = nil) {
        self.jsonEncoder = jsonEncoder
        self.encoder = encoder
    }
    
}

extension EncoderImpl {
    
    static func encode<T>(_ jsonEncoder: JSONEncoder, encoder: Encoder, value: T) throws where T: Encodable {
        let encoder = EncoderImpl(jsonEncoder, encoder: encoder, type: T.self)
        try value.encode(to: encoder)
    }
    
}

extension EncoderImpl: Encoder {
    
    var codingPath: [CodingKey] {
        encoder.codingPath
    }
    
    var userInfo: [CodingUserInfoKey : Any] {
        encoder.userInfo
    }
    
    func container<Key>(keyedBy type: Key.Type) -> KeyedEncodingContainer<Key> where Key : CodingKey {
        let container = encoder.container(keyedBy: type)
        return KeyedEncodingContainer(KeyedContainer<Key>(self, container))
    }
    
    func unkeyedContainer() -> UnkeyedEncodingContainer {
        let container = encoder.unkeyedContainer()
        return UnkeyedContainer(self, container)
    }
    
    func singleValueContainer() -> SingleValueEncodingContainer {
        let container = encoder.singleValueContainer()
        return SingleValueContainer(self, container)
    }
    
}
