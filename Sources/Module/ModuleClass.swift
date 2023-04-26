//
//  ModuleClass.swift
//  HSLiveEngineDemo
//
//  Created by snow on 2023/4/7.
//

import Foundation

open class ModuleClass: NSObject {
    
    public let moduleClass: AnyClass
    
    public init(_ moduleClass: AnyClass) {
        self.moduleClass = moduleClass
        super.init()
    }
    
    public private(set) lazy var methodsByName: [String: ModuleMethod] = {
        var dict: [String: ModuleMethod] = [:]
        var cls: AnyClass? = moduleClass
        var methodCount: UInt32 = 0
        while cls != nil && cls != NSObject.self && cls != NSProxy.self {
            if let methodList = class_copyMethodList(cls, &methodCount) {
                defer {
                    free(methodList)
                }
                for index in 0..<methodCount {
                    let method = methodList[Int(index)]
                    let selector = method_getName(method)
                    let imp = method_getImplementation(method)
                    let selectorName = String(cString: sel_getName(selector))
                    if let name = selectorName.split(separator: ":").first {
                        dict[String(name)] = ModuleMethod(selector: selector, moduleClass: moduleClass)
                    }
                }
            }
            cls = class_getSuperclass(cls)
        }
        return dict
    }()
    
}
