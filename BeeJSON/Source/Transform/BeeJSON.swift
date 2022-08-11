//
//  BeeJSON.swift
//  BeeJSON
//
//  Created by snow on 2022/8/9.
//

import Foundation

public protocol BeeJSONCustomTransformable: _CustomBasicType {}

public protocol BeeJSON: _CustomModelType {}

public protocol BeeJSONEnum: _RawEnumProtocol {}
