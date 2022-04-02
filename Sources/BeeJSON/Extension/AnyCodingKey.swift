//
//  CustomCodingKey.swift
//  BeeJSON
//  
//  Created  by 张绍平 on 2022/3/22
//  
//  
	

import Foundation

public struct AnyCodingKey: CodingKey {
    public var stringValue: String
    public var intValue: Int?

    public init?(stringValue: String) {
        self.stringValue = stringValue
    }

    public init?(intValue: Int) {
        self.stringValue = "\(intValue)"
        self.intValue = intValue
    }
}
