//
//  NSDecimalNumberTransform.swift
//  BeeJSON
//
//  Created by snow on 2022/8/10.
//

import Foundation

open class NSDecimalNumberTransform: TransformType {
    public typealias Object = NSDecimalNumber
    public typealias JSON = String

    public init() {}

    open func transformFromJSON(_ value: Any?) -> NSDecimalNumber? {
        if let string = value as? String {
            return NSDecimalNumber(string: string)
        }
        if let double = value as? Double {
            return NSDecimalNumber(value: double)
        }
        return nil
    }

    open func transformToJSON(_ value: NSDecimalNumber?) -> String? {
        guard let value = value else { return nil }
        return value.stringValue
    }
}
