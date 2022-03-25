//
//  UnwrapProtocol.swift
//  BeeJSON
//  
//  Created  by 张绍平 on 2022/3/15
//  
//  
	

import Foundation

protocol UnwrapProtocol {
    static func unwrap(_ any: Any?) -> Self?
}

fileprivate let formatter: NumberFormatter = {
    let formatter = NumberFormatter()
    formatter.usesGroupingSeparator = false
    formatter.numberStyle = .decimal
    formatter.maximumFractionDigits = 16
    return formatter
}()

extension String: UnwrapProtocol {
    
    static func unwrap(_ any: Any?) -> String? {
        switch any {
        case let value as UInt64:
            return value.description
        case let value as NSNumber:
            return formatter.string(from: value)
        case let value as Bool:
            return value ? "true" : "false"
        case let value as String:
            return value
        default:
            return nil
        }
    }
    
}

extension Bool: UnwrapProtocol {
    
    static func unwrap(_ any: Any?) -> Bool? {
        switch any {
        case let value as String:
            return value == "true"
        case let value as NSNumber:
            return value.boolValue
        case let value as Bool:
            return value
        default:
            return nil
        }
    }
    
}

protocol IntegerUnwrap: FixedWidthInteger, UnwrapProtocol {
    init(_ number: NSNumber)
}

extension IntegerUnwrap {
    
    static func unwrap(_ any: Any?) -> Self? {
        switch any {
        case let value as String:
            return Self.init(value, radix: 10)
        case let value as NSNumber:
            return Self.init(value)
        case let value as Bool:
            return Self.init(value ? 1 : 0)
        default:
            return nil
        }
    }
    
}

extension Int: IntegerUnwrap {}
extension UInt: IntegerUnwrap {}
extension Int8: IntegerUnwrap {}
extension Int16: IntegerUnwrap {}
extension Int32: IntegerUnwrap {}
extension Int64: IntegerUnwrap {}
extension UInt8: IntegerUnwrap {}
extension UInt16: IntegerUnwrap {}
extension UInt32: IntegerUnwrap {}
extension UInt64: IntegerUnwrap {}

protocol FloatUnwrap: LosslessStringConvertible, UnwrapProtocol {
    init(_ number: NSNumber)
}

extension FloatUnwrap {
    
    static func unwrap(_ any: Any?) -> Self? {
        switch any {
        case let value as String:
            return Self.init(value)
        case let value as NSNumber:
            return Self.init(value)
        case let value as Bool:
            return Self.init(value ? 1 : 0)
        default:
            return nil
        }
    }
    
}

extension Float: FloatUnwrap {}
extension Double: FloatUnwrap {}

