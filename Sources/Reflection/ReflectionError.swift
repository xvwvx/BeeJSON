//
//  ReflectionError.swift
//  BeeJSON
//
//  Created by snow on 2022/8/14.
//

import Foundation

public enum ReflectionError: Error {
    case couldNotGetTypeInfo(type: Any.Type)
}
