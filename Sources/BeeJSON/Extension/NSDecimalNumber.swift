//
//  NSDecimalNumber.swift
//  BeeJSON
//  
//  Created  by 张绍平 on 2022/4/13
//  
//  
	

import Foundation

extension NSDecimalNumber {
    static func < (left: NSDecimalNumber, right: NSDecimalNumber) -> Bool {
        return left.compare(right) == .orderedAscending
    }

    static func <= (left: NSDecimalNumber, right: NSDecimalNumber) -> Bool {
        let result = left.compare(right)
        return result == .orderedSame || result == .orderedAscending
    }

    static func == (left: NSDecimalNumber, right: NSDecimalNumber) -> Bool {
        return left.compare(right) == .orderedSame
    }

    static func != (left: NSDecimalNumber, right: NSDecimalNumber) -> Bool {
        return !(left == right)
    }

    static func >= (left: NSDecimalNumber, right: NSDecimalNumber) -> Bool {
        return !(left < right)
    }

    static func > (left: NSDecimalNumber, right: NSDecimalNumber) -> Bool {
        return !(left <= right)
    }

    static func + (left: NSDecimalNumber, right: NSDecimalNumber) -> NSDecimalNumber {
        return left.adding(right)
    }

    static func - (left: NSDecimalNumber, right: NSDecimalNumber) -> NSDecimalNumber {
        return left.subtracting(right)
    }

    static func * (left: NSDecimalNumber, right: NSDecimalNumber) -> NSDecimalNumber {
        return left.multiplying(by: right)
    }

    static func / (left: NSDecimalNumber, right: NSDecimalNumber) -> NSDecimalNumber {
        return left.dividing(by: right)
    }

    static prefix func - (value: NSDecimalNumber) -> NSDecimalNumber {
        return value * NSDecimalNumber(value: -1)
    }
}
