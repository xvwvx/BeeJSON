//
//  DataTransform.swift
//  BeeJSON
//
//  Created by snow on 2022/8/10.
//

import Foundation

open class DataTransform: TransformType {
    public typealias Object = Data
    public typealias JSON = String

    public init() {}

    open func transformFromJSON(_ value: Any?) -> Data? {
        guard let string = value as? String else{
            return nil
        }
        return Data(base64Encoded: string)
    }

    open func transformToJSON(_ value: Data?) -> String? {
        guard let data = value else{
            return nil
        }
        return data.base64EncodedString()
    }
}
