//
//  Cache.swift
//  BeeJSON
//
//  Created by snow on 2022/6/1.
//

import Foundation

class Cache {
    
    private var rwlock = pthread_rwlock_t()
    
    static let shared = Cache()
    private init() {
        let status = pthread_rwlock_init(&rwlock, nil)
        assert(status == 0)
    }
    
    private let cache = NSCache<NSString, NSDictionary>()
    
    func get<Model>(type: Model.Type) -> [String: Any]? {
        pthread_rwlock_rdlock(&rwlock)
        defer {
            pthread_rwlock_unlock(&rwlock)
        }
        let key = String(reflecting: type) as NSString
        return cache.object(forKey: key) as? [String: Any]
    }
    
    func set<Model>(type: Model.Type, value: [String: Any]) {
        pthread_rwlock_wrlock(&rwlock)
        defer {
            pthread_rwlock_unlock(&rwlock)
        }
        let key = String(reflecting: type) as NSString
        cache.setObject(value as NSDictionary, forKey: key)
    }
    
}
