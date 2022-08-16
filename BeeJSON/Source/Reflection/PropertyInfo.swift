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

public extension PropertyInfo {
    
    func getName() -> String {
        var name = name
        let key = "$__lazy_storage_$_"
        if name.starts(with: key) {
            name.removeFirst(key.count)
        }
        return name
    }
    
}
