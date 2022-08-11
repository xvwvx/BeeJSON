//
//  AnyExtension.swift
//  BeeJSON
//
//  Created by snow on 2022/8/9.
//

import Swift

public protocol AnyExtension {}

extension AnyExtension {

    public static func isSelf(_ value: Any) -> Bool {
        return value is Self
    }

    public static func value(from pointer: UnsafeRawPointer) -> Any {
        return pointer.assumingMemoryBound(to: self).pointee
    }

    public static func write(_ value: Any, to pointer: UnsafeMutableRawPointer) {
        if let value = value as? Self {
            pointer.assumingMemoryBound(to: self).pointee = value
        }
    }

    public static func takeValue(from any: Any) -> Self? {
        return any as? Self
    }
    
}

public func withAnyExtension(_ type: Any.Type) -> AnyExtension.Type {
    ProtocolTypeContainer(type: type).anyExtension
}
