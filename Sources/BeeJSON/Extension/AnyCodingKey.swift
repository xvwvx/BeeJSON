//
//  CustomCodingKey.swift
//  BeeJSON
//  
//  Created  by 张绍平 on 2022/3/22
//  
//  
	

import Foundation

struct AnyCodingKey: CodingKey {
    var stringValue: String
    var intValue: Int?

    init?(stringValue: String) {
        self.stringValue = stringValue
    }

    init?(intValue: Int) {
        self.stringValue = "\(intValue)"
        self.intValue = intValue
    }
}
