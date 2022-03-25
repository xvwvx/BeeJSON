//
//  JSONIgnore.swift
//  BeeJSON
//  
//  Created  by 张绍平 on 2022/3/21
//  
//  
	

import Foundation

@propertyWrapper
public struct JSONIgnore<T>: Encodable {
    public var wrappedValue: T
    
    public init(_ value: T) {
        wrappedValue = value
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encodeNil()
    }
}
