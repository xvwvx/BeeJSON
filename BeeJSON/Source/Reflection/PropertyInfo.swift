//
//  PropertyInfo.swift
//  BeeJSON
//
//  Created by snow on 2022/8/9.
//

import Swift

public struct PropertyInfo {
    public let name: String
    public let type: Any.Type
    public let isVar: Bool
    public let offset: Int
}

