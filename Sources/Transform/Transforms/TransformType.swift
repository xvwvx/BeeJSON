//
//  TransformType.swift
//  BeeJSON
//
//  Created by snow on 2022/8/9.
//

public protocol TransformType {
    associatedtype Object
    associatedtype JSON

    func transformFromJSON(_ value: Any?) -> Object?
    func transformToJSON(_ value: Object?) -> JSON?
}
