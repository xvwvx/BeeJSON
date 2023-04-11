//
//  ExtendCustomModelTypeCache.swift
//  BeeJSON
//
//  Created by snow on 2022/8/10.
//

#if canImport(UIKit)
import UIKit
#endif

import Runtime

class CustomModelTypeCache {
    
    struct Item {
        let name: String
        let type: Any.Type
        let offset: Int
        let transformFrom: ((Any?) -> (Any?))?
        let transformTo: ((Any?) -> (Any?))?
    }

    static let shared = CustomModelTypeCache()
    
    private var rwlock = pthread_rwlock_t()
    
    private var dict: [String: [Item]] = [:]
    
    private init() {
        let status = pthread_rwlock_init(&rwlock, nil)
        assert(status == 0)
        
        #if canImport(UIKit)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(didReceiveMemoryWarning),
                                               name: UIApplication.didReceiveMemoryWarningNotification,
                                               object: nil)
        #endif
    }
    
    @objc func didReceiveMemoryWarning() {
        pthread_rwlock_wrlock(&rwlock)
        defer {
            pthread_rwlock_unlock(&rwlock)
        }
        dict = [:]
    }
    
    func getOrCreate<T: _CustomModelType>(type: T.Type) throws -> [Item] {
        let key = String(reflecting: type)
        do {
            pthread_rwlock_rdlock(&rwlock)
            defer {
                pthread_rwlock_unlock(&rwlock)
            }
            if let value = dict[key] {
                return value
            }
        }
        
        var value = T.init()
        let base = try withPointer(&value) { $0 }
        var mapper = CustomModelMapper()
        value.mapping(mapper: &mapper)
        
        let info = try Runtime.typeInfo(of: T.self)
        let baseKey = Int(bitPattern: base)
        let names = info.properties.map({ $0.name })
        let items: [Item] = info.properties.compactMap { property in
            let key = baseKey + property.offset
            if mapper.propertyExcluded(key: key) {
                return nil
            }
            let handler = mapper.mappingHandler(key: key)
            guard property.type is _Transformable.Type
                || handler?.transformFrom != nil
                || handler?.transformTo != nil else {
                return nil
            }
            
            let name: String? = {
                if let name = handler?.name {
                    return name
                }
                var name = property.name
                let lazyKey = "$__lazy_storage_$_"
                if name.starts(with: lazyKey) {
                    // 处理 lazy
                    if Transformer.ignoreLazy {
                        return nil
                    }
                    name.removeFirst(lazyKey.count)
                } else if name.starts(with: "_") {
                    // 处理 @propertyWrapper
                    name.removeFirst()
                    if names.contains(name) {
                        return nil
                    }
                }
                return name
            }()
            guard let name = name else {
                return nil
            }
            
            return Item(name: name,
                        type: property.type,
                        offset: property.offset,
                        transformFrom: handler?.transformFrom,
                        transformTo: handler?.transformTo)
        }
        
        pthread_rwlock_wrlock(&rwlock)
        defer {
            pthread_rwlock_unlock(&rwlock)
        }
        dict[key] = items
        return items
    }
}
