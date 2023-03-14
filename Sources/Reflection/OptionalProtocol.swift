//
//  OptionalProtocol.swift
//  BeeJSON
//
//  Created by snow on 2022/11/21.
//

import Foundation

private protocol OptionalType {}
extension Optional: OptionalType {}

public func isOptionalType(_ type: Any.Type) -> Bool {
    return type is OptionalType.Type
}
