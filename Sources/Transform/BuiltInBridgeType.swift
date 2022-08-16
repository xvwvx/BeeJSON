//
//  BuiltInBridgeType.swift
//  BeeJSON
//
//  Created by snow on 2022/8/9.
//

import Foundation

protocol _BuiltInBridgeType: _Transformable {

    static func _transform(from object: Any) throws -> _BuiltInBridgeType?
    func _plainValue() throws -> Any?
}

extension NSString: _BuiltInBridgeType {

    static func _transform(from object: Any) throws -> _BuiltInBridgeType? {
        if let str = try String.transform(from: object) {
            return NSString(string: str)
        }
        return nil
    }

    func _plainValue() throws -> Any? {
        return self
    }
}

extension NSNumber: _BuiltInBridgeType {

    static func _transform(from object: Any) throws -> _BuiltInBridgeType? {
        switch object {
        case let num as NSNumber:
            return num
        case let str as NSString:
            let lowercase = str.lowercased
            if lowercase == "true" {
                return NSNumber(booleanLiteral: true)
            } else if lowercase == "false" {
                return NSNumber(booleanLiteral: false)
            } else {
                // normal number
                let formatter = NumberFormatter()
                formatter.numberStyle = .decimal
                return formatter.number(from: str as String)
            }
        default:
            return nil
        }
    }

    func _plainValue() throws -> Any? {
        return self
    }
}

extension NSArray: _BuiltInBridgeType {
    
    static func _transform(from object: Any) throws -> _BuiltInBridgeType? {
        return object as? NSArray
    }

    func _plainValue() throws -> Any? {
        return try (self as? Array<Any>)?.plainValue()
    }
}

extension NSDictionary: _BuiltInBridgeType {
    
    static func _transform(from object: Any) throws -> _BuiltInBridgeType? {
        return object as? NSDictionary
    }

    func _plainValue() throws -> Any? {
        return try (self as? Dictionary<String, Any>)?.plainValue()
    }
}
