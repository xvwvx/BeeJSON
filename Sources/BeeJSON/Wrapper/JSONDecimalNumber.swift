//
//  JSONDecimalNumber.swift
//  BeeJSON
//  
//  Created  by 张绍平 on 2022/3/21
//  
//  
	

import Foundation

@propertyWrapper
public struct JSONDecimalNumber: Codable {
    
    public var wrappedValue: NSDecimalNumber
    
    public init(_ value: NSDecimalNumber = .zero) {
        wrappedValue = value
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let value = try? container.decode(String.self) {
            wrappedValue = NSDecimalNumber(string: value)
        } else if let value = try? container.decode(Double.self) {
            wrappedValue = NSDecimalNumber(value: value)
        } else {
            wrappedValue = .zero
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(wrappedValue.stringValue)
    }
    
}
