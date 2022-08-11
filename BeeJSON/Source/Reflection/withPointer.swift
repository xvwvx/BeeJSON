//
//  withPointer.swift
//  BeeJSON
//
//  Created by snow on 2022/8/9.
//

import Swift

func withPointer<Value, Result>(_ value: inout Value, _ body: (UnsafeMutableRawPointer) throws -> Result) throws -> Result {
    let kind = _metadataKind(Value.self)
    switch kind {
    case 0:
        // class
        return try withUnsafePointer(to: &value) {
            return try $0.withMemoryRebound(to: UnsafeMutableRawPointer.self, capacity: 1) {
                try body($0.pointee)
            }
        }
    case 0x200:
        // struct
        return try withUnsafePointer(to: &value) {
            let pointer = UnsafeMutableRawPointer(mutating: $0)
            return try body(pointer)
        }
    default:
        fatalError()
    }
}

