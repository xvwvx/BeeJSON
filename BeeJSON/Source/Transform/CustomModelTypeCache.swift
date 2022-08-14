//
//  ExtendCustomModelTypeCache.swift
//  BeeJSON
//
//  Created by snow on 2022/8/10.
//

import UIKit

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
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(didReceiveMemoryWarning),
                                               name: UIApplication.didReceiveMemoryWarningNotification,
                                               object: nil)
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
        
        let info = typeInfo(of: T.self)
        let baseKey = Int(bitPattern: base)
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
            
            let name: String = {
                if let name = handler?.name {
                    return name
                }
                return property.getName()
            }()
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
