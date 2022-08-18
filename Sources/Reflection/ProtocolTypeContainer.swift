//
//  ProtocolTypeContainer.swift
//  BeeJSON
//
//  Created by snow on 2022/8/9.
//

import Swift

public struct ProtocolTypeContainer {
    let type: Any.Type
    let witnessTable = 0
    
    public init(type: Any.Type) {
        self.type = type
    }
    
    @inlinable public func asExtension<T>(to type: T.Type) -> T {
        return unsafeBitCast(self, to: type)
    }
    
    @inlinable public static func asExtension<T>(from: Any.Type, to: T.Type) -> T {
        let container = ProtocolTypeContainer(type: from)
        return unsafeBitCast(container, to: to)
    }
}
