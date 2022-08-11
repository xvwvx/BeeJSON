//
//  TransformCache.swift
//  BeeJSON
//
//  Created by snow on 2022/8/9.
//

import Foundation

struct CacheItem {
    let name: String
    let type: Any.Type
    let offset: Int
//    let transformer: TransformType?
}

class TypeCache {
    
    private var rwlock = pthread_rwlock_t()
    
    static let shared = TypeCache()
    private init() {
        let status = pthread_rwlock_init(&rwlock, nil)
        assert(status == 0)
    }
    
    private var cache: [String: CacheItem] = [:]
    
    func get<T>(type: T.Type) -> CacheItem? {
        pthread_rwlock_rdlock(&rwlock)
        defer {
            pthread_rwlock_unlock(&rwlock)
        }
        let key = String(reflecting: type)
        return cache[key]
    }
    
    func set<T>(type: T.Type, value: CacheItem) {
        pthread_rwlock_wrlock(&rwlock)
        defer {
            pthread_rwlock_unlock(&rwlock)
        }
        let key = String(reflecting: type)
        cache[key] = value
    }
    
}
