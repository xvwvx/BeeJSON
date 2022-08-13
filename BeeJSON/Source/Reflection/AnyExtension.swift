//
//  AnyExtension.swift
//  BeeJSON
//
//  Created by snow on 2022/8/9.
//

import Swift

public protocol AnyExtension {}

extension AnyExtension {

    @inlinable public static func isSelf(_ value: Any) -> Bool {
        return value is Self
    }
    
    @inlinable public static func asSelf(_ value: Any) -> Self? {
        return value as? Self
    }
    
    @inlinable public static func read(pointer: UnsafeRawPointer) -> Self {
        return pointer.assumingMemoryBound(to: self).pointee
    }
    
    @inlinable public static func write(pointer: UnsafeMutableRawPointer, value: Any) {
        if let value = value as? Self {
            pointer.assumingMemoryBound(to: self).pointee = value
        }
    }
    
    @inlinable public static func write(pointer: UnsafeMutableRawPointer, value: Any?) {
        if let value = value as? Self {
            pointer.assumingMemoryBound(to: self).pointee = value
        }
    }
    
}

@inlinable public func withAnyExtension(_ type: Any.Type) -> AnyExtension.Type {
    let container = ProtocolTypeContainer(type: type)
    return unsafeBitCast(container, to: AnyExtension.Type.self)
}
