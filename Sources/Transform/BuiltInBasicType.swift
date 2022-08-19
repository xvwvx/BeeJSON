//
//  BuiltInTransformable.swift
//  BeeJSON
//
//  Created by snow on 2022/8/9.
//

import Foundation

protocol _BuiltInBasicType: _Transformable {
    static func _transform(from object: Any) throws -> Self?
    func _plainValue() throws -> Any?
}

// Suppport integer type

protocol IntegerPropertyProtocol: FixedWidthInteger, _BuiltInBasicType {
    init?(_ text: String, radix: Int)
    init(_ number: NSNumber)
}

extension IntegerPropertyProtocol {

    static func _transform(from object: Any) throws -> Self? {
        switch object {
        case let str as String:
            return Self(str, radix: 10)
        case let num as NSNumber:
            return Self(num)
        default:
            return nil
        }
    }
    
    func _plainValue() throws -> Any? {
        return self
    }
}

extension Int: IntegerPropertyProtocol {}
extension UInt: IntegerPropertyProtocol {}
extension Int8: IntegerPropertyProtocol {}
extension Int16: IntegerPropertyProtocol {}
extension Int32: IntegerPropertyProtocol {}
extension Int64: IntegerPropertyProtocol {}
extension UInt8: IntegerPropertyProtocol {}
extension UInt16: IntegerPropertyProtocol {}
extension UInt32: IntegerPropertyProtocol {}
extension UInt64: IntegerPropertyProtocol {}

extension Bool: _BuiltInBasicType {

    static func _transform(from object: Any) throws -> Bool? {
        switch object {
        case let str as NSString:
            let lowerCase = str.lowercased
            if ["0", "false"].contains(lowerCase) {
                return false
            }
            if ["1", "true"].contains(lowerCase) {
                return true
            }
            return nil
        case let num as NSNumber:
            return num.boolValue
        default:
            return nil
        }
    }

    func _plainValue() throws -> Any? {
        return self
    }
}

// Support float type

protocol FloatPropertyProtocol: _BuiltInBasicType, LosslessStringConvertible {
    init(_ number: NSNumber)
}

extension FloatPropertyProtocol {

    static func _transform(from object: Any) throws -> Self? {
        switch object {
        case let str as String:
            return Self(str)
        case let num as NSNumber:
            return Self(num)
        default:
            return nil
        }
    }

    func _plainValue() throws -> Any? {
        return self
    }
}

extension Float: FloatPropertyProtocol {}
extension Double: FloatPropertyProtocol {}

extension String: _BuiltInBasicType {

    static func _transform(from object: Any) throws -> String? {
        switch object {
        case let str as String:
            return str
        case let num as NSNumber:
            // Boolean Type Inside
            if NSStringFromClass(type(of: num)) == "__NSCFBoolean" {
                if num.boolValue {
                    return "true"
                } else {
                    return "false"
                }
            }
            return num.stringValue
        case is NSNull:
            return nil
        default:
            return "\(object)"
        }
    }

    func _plainValue() throws -> Any? {
        return self
    }
}

// MARK: Optional Support

extension Optional: _BuiltInBasicType {

    static func _transform(from object: Any) throws -> Optional? {
        if let value = try (Wrapped.self as? _Transformable.Type)?.transform(from: object) as? Wrapped {
            return Optional(value)
        } else if let value = object as? Wrapped {
            return Optional(value)
        }
        return nil
    }

    func _plainValue() throws -> Any? {
        if case .some(let value) = self {
            if let transformable = value as? _Transformable {
                return try transformable.plainValue()
            } else {
                return value
            }
        }
        return nil
    }
}

// MARK: Collection Support : Array & Set

extension Collection {

    static func _collectionTransform(from object: Any) throws -> [Iterator.Element]? {
        guard let arr = object as? [Any] else {
            return nil
        }
        typealias Element = Iterator.Element
        var result: [Element] = [Element]()
        for item in arr {
            if let element = try (Element.self as? _Transformable.Type)?.transform(from: item) as? Element {
                result.append(element)
            } else if let element = item as? Element {
                result.append(element)
            }
        }
        return result
    }

    func _collectionPlainValue() throws -> Any? {
        typealias Element = Iterator.Element
        var result: [Any] = [Any]()
        for item in self {
            if let transformable = item as? _Transformable, let transValue = try transformable.plainValue() {
                result.append(transValue)
            }
        }
        return result
    }
}

extension Array: _BuiltInBasicType {

    static func _transform(from object: Any) throws -> [Element]? {
        return try self._collectionTransform(from: object)
    }

    func _plainValue() throws -> Any? {
        return try self._collectionPlainValue()
    }
}

extension Set: _BuiltInBasicType {

    static func _transform(from object: Any) throws -> Set<Element>? {
        if let arr = try self._collectionTransform(from: object) {
            return Set(arr)
        }
        return nil
    }

    func _plainValue() throws -> Any? {
        return try self._collectionPlainValue()
    }
}

// MARK: Dictionary Support

extension Dictionary: _BuiltInBasicType {

    static func _transform(from object: Any) throws -> [Key: Value]? {
        guard let dict = object as? [String: Any] else {
            return nil
        }
        var result = [Key: Value]()
        for (key, value) in dict {
            if let sKey = key as? Key {
                if let nValue = try (Value.self as? _Transformable.Type)?.transform(from: value) as? Value {
                    result[sKey] = nValue
                } else if let nValue = value as? Value {
                    result[sKey] = nValue
                }
            }
        }
        return result
    }

    func _plainValue() throws -> Any? {
        var result = [String: Any]()
        for (key, value) in self {
            if let key = key as? String {
                if let transformable = value as? _Transformable {
                    if let transValue = try transformable.plainValue() {
                        result[key] = transValue
                    }
                }
            }
        }
        return result
    }
}

