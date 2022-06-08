//
//  JSONSerialization.swift
//  BeeJSONDemoTests
//
//  Created by snow on 2022/6/8.
//

import Foundation


extension JSONSerialization {
    
    @objc
    class func string(withJSONObject obj: Any, options opt: JSONSerialization.WritingOptions) throws -> String {
        let data = try data(withJSONObject: obj, options: opt)
        if let str = String(data: data, encoding: .utf8) {
            return str
        }
        throw NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "序列化失败"])
    }
    
    @objc
    class func jsonObject(with str: String, options opt: JSONSerialization.ReadingOptions = []) throws -> Any {
        if let data = str.data(using: .utf8) {
            return try jsonObject(with: data, options: opt)
        }
        throw NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "无效数据"])
    }
}
