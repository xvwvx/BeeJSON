//
//  TransformError.swift
//  BeeJSON
//
//  Created by snow on 2022/8/16.
//

import Foundation

public enum TransformError: Error {
    case validEncodeType(Any.Type)
    case validDecodeType(Any.Type)
    case validJSONObject(Error)
}
