//
//  CustomBasicType.swift
//  BeeJSON
//
//  Created by snow on 2022/8/9.
//

import Foundation

public protocol _CustomBasicType: _Transformable {
    static func _transform(from object: Any) -> Self?
    func _plainValue() -> Any?
}
