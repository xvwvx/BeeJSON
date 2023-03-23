//
//  JSONDecoderImpl.swift
//  BeeJSON
//
//  Created by snow on 2022/11/21.
//

import Foundation

extension JSONDecoder {
    
    struct _Options {
        let dateDecodingStrategy: DateDecodingStrategy
        let dataDecodingStrategy: DataDecodingStrategy
        let nonConformingFloatDecodingStrategy: NonConformingFloatDecodingStrategy
        let keyDecodingStrategy: KeyDecodingStrategy
        let userInfo: [CodingUserInfoKey: Any]
    }
    
    var options: _Options {
        return _Options(dateDecodingStrategy: dateDecodingStrategy,
                        dataDecodingStrategy: dataDecodingStrategy,
                        nonConformingFloatDecodingStrategy: nonConformingFloatDecodingStrategy,
                        keyDecodingStrategy: keyDecodingStrategy,
                        userInfo: userInfo)
    }
    
}

struct JSONDecoderImpl {
    let codingPath: [CodingKey]
    let userInfo: [CodingUserInfoKey: Any]
    
    let any: Any
    let options: JSONDecoder._Options
    let type: Any.Type?
    
    init(userInfo: [CodingUserInfoKey: Any], from any: Any, codingPath: [CodingKey], options: JSONDecoder._Options, type: Any.Type?) {
        self.userInfo = userInfo
        self.codingPath = codingPath
        self.any = any
        self.options = options
        self.type = type
    }
}

private var _iso8601Formatter: ISO8601DateFormatter = {
    let formatter = ISO8601DateFormatter()
    formatter.formatOptions = .withInternetDateTime
    return formatter
}()

fileprivate func getPropertyItems<Key: CodingKey, Type: BeeJSON>(keyedBy _: Key.Type, type _: Type.Type) throws -> [PropertyItem] {
    // class 不能做 cache
    //    if let result = Cache.shared.get(type: type) {
    //        return result
    //    }
    
    func unwrap(_ value: Any) -> Any? {
        if isOptionalType(type(of: value)) {
            if case Optional<Any>.some(let value) = value {
                return unwrap(value)
            }
            return nil
        }
        return value
    }
    
    var value = Type.init()
    let info = typeInfo(of: Type.self)
    let base = try withPointer(&value) { $0 }
    let result = info.properties
        .reduce(into: [PropertyItem](), { result, element in
            let name: String? = {
                var name = element.name
                if Key(stringValue: name) != nil {
                    return name
                }
                if name.starts(with: "_") {
                    name.removeFirst()
                    if Key(stringValue: name) != nil {
                        return name
                    }
                }
                return nil
            }()
            if let name = name {
                let pointer = base.advanced(by: element.offset)
                let anyExtension = withAnyExtension(element.type)
                let value = anyExtension.read(pointer: pointer)
                let item = PropertyItem(name: name, value: unwrap(value), type: element.type)
                result.append(item)
            }
        })
    //    Cache.shared.set(type: type, value: result)
    return result
}

extension JSONDecoderImpl: Decoder {
    
    func container<Key>(keyedBy type: Key.Type) throws -> KeyedDecodingContainer<Key> where Key : CodingKey {
        if var dictionary = self.any as? [String: Any] {
            if let beeJSONType = self.type as? BeeJSON.Type {
                let items = try getPropertyItems(keyedBy: type, type: beeJSONType)
                for item in items {
                    if let value = dictionary[item.name],
                       let decodableType = item.type as? Decodable.Type {
                        let decoder = JSONDecoderImpl(userInfo: self.userInfo, from: value, codingPath: [], options: self.options, type: type)
                        if let value = try? decoder.unwrapOptional(as: decodableType) {
                            dictionary[item.name] = value
                            continue
                        }
                    }
                    
                    dictionary[item.name] = item.value
                }
            }
            
            let container = KeyedContainer<Key>(
                impl: self,
                codingPath: codingPath,
                dictionary: dictionary
            )
            return KeyedDecodingContainer(container)
        }
        
        throw DecodingError.typeMismatch(
            Dictionary<String, Any>.self,
            DecodingError.Context(
                codingPath: self.codingPath,
                debugDescription: "Expected to decode dictionary but found \(self.any) instead."
            )
        )
    }
    
    func unkeyedContainer() throws -> UnkeyedDecodingContainer {
        if let array = self.any as? [Any] {
            return UnkeyedContainer(impl: self, codingPath: self.codingPath, array: array)
        }
        
        throw DecodingError.typeMismatch(
            Array<Any>.self,
            DecodingError.Context(
                codingPath: self.codingPath,
                debugDescription: "Expected to decode array but found \(self.any) instead."
            )
        )
    }
    
    func singleValueContainer() throws -> SingleValueDecodingContainer {
        SingleValueContainer(impl: self, codingPath: [], any: self.any, type: self.type)
    }
    
}

extension JSONDecoderImpl {
    
    func unwrapOptional<T: Decodable>(as type: T.Type) throws -> T {
        if type == Date?.self {
            return try self.unwrapDate() as! T
        }
        if type == Data?.self {
            return try self.unwrapData() as! T
        }
        if type == URL?.self {
            return try self.unwrapURL() as! T
        }
        if type == Decimal?.self {
            return try self.unwrapDecimal() as! T
        }
        
        return try self.unwrap(as: type)
    }
    
    func unwrap<T: Decodable>(as type: T.Type) throws -> T {
        if let value = self.any as? T {
            return value
        }
        
        if type == Date.self {
            return try self.unwrapDate() as! T
        }
        if type == Data.self {
            return try self.unwrapData() as! T
        }
        if type == URL.self {
            return try self.unwrapURL() as! T
        }
        if type == Decimal.self {
            return try self.unwrapDecimal() as! T
        }
        
        return try T(from: self)
    }
    
    private func unwrapDate() throws -> Date {
        switch self.options.dateDecodingStrategy {
        case .deferredToDate:
            return try Date(from: self)
            
        case .secondsSince1970:
            let container = SingleValueContainer(impl: self, codingPath: self.codingPath, any: self.any, type: Date.self)
            let double = try container.decode(Double.self)
            return Date(timeIntervalSince1970: double)
            
        case .millisecondsSince1970:
            let container = SingleValueContainer(impl: self, codingPath: self.codingPath, any: self.any, type: Date.self)
            let double = try container.decode(Double.self)
            return Date(timeIntervalSince1970: double / 1000.0)
            
        case .iso8601:
            if #available(macOS 10.12, iOS 10.0, watchOS 3.0, tvOS 10.0, *) {
                let container = SingleValueContainer(impl: self, codingPath: self.codingPath, any: self.any, type: Date.self)
                let string = try container.decode(String.self)
                guard let date = _iso8601Formatter.date(from: string) else {
                    throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: self.codingPath, debugDescription: "Expected date string to be ISO8601-formatted."))
                }
                
                return date
            } else {
                fatalError("ISO8601DateFormatter is unavailable on this platform.")
            }
            
        case .formatted(let formatter):
            let container = SingleValueContainer(impl: self, codingPath: self.codingPath, any: self.any, type: Date.self)
            let string = try container.decode(String.self)
            guard let date = formatter.date(from: string) else {
                throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: self.codingPath, debugDescription: "Date string does not match format expected by formatter."))
            }
            return date
            
        case .custom(let closure):
            return try closure(self)
        }
    }
    
    private func unwrapData() throws -> Data {
        switch self.options.dataDecodingStrategy {
        case .deferredToData:
            return try Data(from: self)
            
        case .base64:
            let container = SingleValueContainer(impl: self, codingPath: self.codingPath, any: self.any, type: Data.self)
            let string = try container.decode(String.self)
            
            guard let data = Data(base64Encoded: string) else {
                throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: self.codingPath, debugDescription: "Encountered Data is not valid Base64."))
            }
            
            return data
            
        case .custom(let closure):
            return try closure(self)
        }
    }
    
    private func unwrapURL() throws -> URL {
        let container = SingleValueContainer(impl: self, codingPath: self.codingPath, any: self.any, type: URL.self)
        let string = try container.decode(String.self)
        
        guard let url = URL(string: string) else {
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: self.codingPath,
                                                                    debugDescription: "Invalid URL string."))
        }
        return url
    }
    
    private func unwrapDecimal() throws -> Decimal {
        guard let numberString = self.any as? String else {
            throw DecodingError.typeMismatch(Decimal.self, DecodingError.Context(codingPath: self.codingPath, debugDescription: ""))
        }
        
        guard let decimal = Decimal(string: numberString) else {
            throw DecodingError.dataCorrupted(.init(
                codingPath: self.codingPath,
                debugDescription: "Parsed JSON number <\(numberString)> does not fit in \(Decimal.self)."))
        }
        
        return decimal
    }
    
    func unwrap<T>(_ type: T.Type, value: Any?) -> T? where T: Decodable {
        if let value = value as? T {
            return value
        }
        
        if let value = value,
           let proto = type as? _Transformable.Type,
           let value = try? proto.transform(from: value) as? T {
            return value
        }
        return nil
    }
    
}

