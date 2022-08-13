//
//  Mapper.swift
//  BeeJSON
//
//  Created by snow on 2022/8/9.
//

struct MappingPropertyHandler {
    let name: String?
    let transformFrom: ((Any?) -> (Any?))?
    let transformTo: ((Any?) -> (Any?))?
}

public struct CustomModelMapper {
    
    private(set) var mappingHandlers: [Int: MappingPropertyHandler] = [:]
    private(set) var excludeProperties: Set<Int> = []
    
    internal func mappingHandler(key: Int) -> MappingPropertyHandler? {
        return self.mappingHandlers[key]
    }
    
    internal func propertyExcluded(key: Int) -> Bool {
        return self.excludeProperties.contains(key)
    }
    
    public mutating func specify<T>(property: inout T, name: String) {
        let pointer = withUnsafePointer(to: &property, { $0 })
        let key = Int(bitPattern: pointer)
        mappingHandlers[key] = MappingPropertyHandler(name: name, transformFrom: nil, transformTo: nil)
    }
    
    public mutating func specify<Transform: TransformType>(property: inout Transform.Object, name: String? = nil, transformer: Transform? = nil) {
        var assignmentClosure: ((Any?) -> (Any?))?
        var takeValueClosure: ((Any?) -> (Any?))?
        if let transformer = transformer {
            assignmentClosure = { jsonValue in
                return transformer.transformFromJSON(jsonValue)
            }
            takeValueClosure = { objectValue in
                if let _value = objectValue as? Transform.Object {
                    return transformer.transformToJSON(_value)
                }
                return nil
            }
        }
        
        let pointer = withUnsafePointer(to: &property, { $0 })
        let key = Int(bitPattern: pointer)
        mappingHandlers[key] = MappingPropertyHandler(name: name, transformFrom: assignmentClosure, transformTo: takeValueClosure)
    }
    
    public mutating func exclude<T>(property: inout T) {
        let pointer = withUnsafePointer(to: &property, { $0 })
        let key = Int(bitPattern: pointer)
        excludeProperties.insert(key)
    }
    
}
