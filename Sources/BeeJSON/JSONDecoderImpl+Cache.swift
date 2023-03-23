//
//  JSONDecoderImpl+Cache.swift
//  BeeJSON
//
//  Created by snow on 2022/11/21.
//

import Foundation

struct PropertyItem {
    let name: String
    let value: Any?
    let type: Any.Type
}

class Cache {
    private var rwlock = pthread_rwlock_t()
    
    static let shared = Cache()
    private init() {
        let status = pthread_rwlock_init(&rwlock, nil)
        assert(status == 0)
    }
    
    private var cache: [String: [PropertyItem]] = [:]
    
    func get(type: Any.Type) -> [PropertyItem]? {
        pthread_rwlock_rdlock(&rwlock)
        defer {
            pthread_rwlock_unlock(&rwlock)
        }
        let key = String(reflecting: type)
        return cache[key]
    }
    
    func set(type: Any.Type, value: [PropertyItem]) {
        pthread_rwlock_wrlock(&rwlock)
        defer {
            pthread_rwlock_unlock(&rwlock)
        }
        let key = String(reflecting: type)
        cache[key] = value
    }
    
}
