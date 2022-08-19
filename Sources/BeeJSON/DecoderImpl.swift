//
//  DecoderImpl.swift
//  BeeJSON
//  
//  Created  by 张绍平 on 2022/3/14
//  
//  
	

import Foundation

public class BeeJSONDecoder: JSONDecoder {
    
    private struct Proxy: Decodable {
        let decoder: Decoder
        
        init(from decoder: Decoder) throws {
            self.decoder = decoder
        }
    }
    
    public override func decode<T>(_ type: T.Type, from data: Data) throws -> T where T : Decodable {
        let proxy = try super.decode(Proxy.self, from: data)
        let value = try DecoderImpl.decode(type, decoder: proxy.decoder, jsonDecoder: self)
        return value
    }
}

struct DecoderImpl {
    
    let jsonDecoder: JSONDecoder
    let decoder: Decoder
    
    init(_ jsonDecoder: JSONDecoder, decoder: Decoder, type: Any.Type? = nil) {
        self.jsonDecoder = jsonDecoder
        self.decoder = decoder
        if let proto = type as? BeeJSON.Type {
            defaultValues = proto.defaultValues()
        } else {
            defaultValues = [:]
        }
    }
    
    fileprivate let defaultValues: [String: Any]
    
}

extension DecoderImpl {
    
    static func decode<T>(_ type: T.Type, decoder: Decoder, jsonDecoder: JSONDecoder) throws -> T where T : Decodable {
        let value = try T.init(from: DecoderImpl(jsonDecoder, decoder: decoder, type: T.self))
        return value
    }
    
    func unwrap<T>(_ type: T.Type, value: Any?) -> T? where T: Decodable {
        if let value = value,
           let proto = type as? _Transformable.Type,
           let value = try? proto.transform(from: value) as? T {
            return value
        }
        return nil
    }
    
    func unwrap<Key, T>(_ type: T.Type, forKey key: Key, value: Any?) -> T? where Key: CodingKey, T: Decodable {
        if let value = unwrap(type, value: value) {
            return value
        }
        
        if let value = defaultValues[key.stringValue] as? T {
            return value
        }
        
        // 针对数组，字典，特殊处理
        if let value = [] as? T ?? [:] as? T {
            return value
        }
        
        return nil
    }
  
}

extension DecoderImpl: Decoder {
    
    public var codingPath: [CodingKey] {
        decoder.codingPath
    }
    
    public var userInfo: [CodingUserInfoKey : Any] {
        decoder.userInfo
    }
    
    public func container<Key>(keyedBy type: Key.Type) throws -> KeyedDecodingContainer<Key> where Key : CodingKey {
        let container = try decoder.container(keyedBy: type)
        return KeyedDecodingContainer(KeyedContainer(self, container))
    }
    
    public func unkeyedContainer() throws -> UnkeyedDecodingContainer {
        let container = try decoder.unkeyedContainer()
        return UnkeyedContainer(self, container)
    }
    
    public func singleValueContainer() throws -> SingleValueDecodingContainer {
        let container = try decoder.singleValueContainer()
        return SingleValueContainer(self, container)
    }
    
}
