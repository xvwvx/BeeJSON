//
//  CustomBasicType.swift
//  BeeJSON
//
//  Created by snow on 2022/8/9.
//

import Foundation

public protocol _CustomBasicType: _Transformable {
    static func _transform(from object: Any) throws -> Self?
    func _plainValue() throws -> Any?
}

public extension _CustomBasicType where Self: Codable {
    
    static func _transform(from object: Any) throws -> Self? {
        let data: Data? = try {
            switch object {
            case let data as Data:
                return data
            case let str as String:
                return str.data(using: .utf8)!
            default:
                if JSONSerialization.isValidJSONObject(object) {
                    return try JSONSerialization.data(withJSONObject: object, options: .fragmentsAllowed)
                }
                return nil
            }
        }()
        if let data = data {
            return try BeeJSONDecoder().decode(Self.self, from: data)
        }
        return nil
    }
    
    func _plainValue() throws -> Any? {
        let data = try BeeJSONEncoder().encode(self)
        return try JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed)
    }
    
}
