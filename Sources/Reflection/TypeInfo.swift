//
//  TypeInfo.swift
//  BeeJSON
//
//  Created by snow on 2022/8/9.
//

import Swift

public struct TypeInfo {
    public let type: Any.Type
    public let properties: [PropertyInfo]
}

public func typeInfo(of type: Any.Type) -> TypeInfo {
    let count = _getRecursiveChildCount(type)
    let properties = (0..<count).compactMap({ index -> PropertyInfo? in
        var field = FieldReflectionMetadata()
        let childType = _getChildMetadata(type, index: index, fieldMetadata: &field)
        defer {
            field.freeFunc?(field.name)
        }
        
        guard let cString = field.name else {
            return nil
        }
  
        let name = String(cString: cString)
        let childOffset = _getChildOffset(type, index: index)
        return PropertyInfo(name: name, type: childType, isVar: field.isVar, offset: childOffset)
    })
    return TypeInfo(type: type, properties: properties)
}
