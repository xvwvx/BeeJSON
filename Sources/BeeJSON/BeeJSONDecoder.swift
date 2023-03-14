//
//  BeeJSONDecoder.swift
//  BeeJSON
//
//  Created by snow on 2022/11/21.
//

import Foundation

open class BeeJSONDecoder: JSONDecoder {
    
    public override func decode<T>(_ type: T.Type, from data: Data) throws -> T where T : Decodable {
        let any = try JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed)
        return try JSONDecoderImpl(userInfo: self.userInfo, from: any, codingPath: [], options: self.options, type: type).unwrap(as: T.self)
    }
    
}
