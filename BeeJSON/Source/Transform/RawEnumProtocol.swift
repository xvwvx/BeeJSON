//
//  EnumType.swift
//  BeeJSON
//
//  Created by snow on 2022/8/9.
//

import Foundation

public protocol _RawEnumProtocol: _Transformable {

    static func _transform(from object: Any) -> Self?
    func _plainValue() -> Any?
}

extension RawRepresentable where Self: _RawEnumProtocol {

    public static func _transform(from object: Any) throws -> Self? {
        if let transformableType = RawValue.self as? _Transformable.Type {
            if let typedValue = try transformableType.transform(from: object) as? RawValue {
                return Self(rawValue: typedValue)
            }
        }
        return nil
    }

    public func _plainValue() -> Any? {
        return self.rawValue
    }
}
