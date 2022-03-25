//
//  BeeJSON.swift
//  BeeJSON
//
//  Created  by 张绍平 on 2022/3/14
//
//
    

import Foundation

public protocol BeeJSON {
    
    static func defaultValues() ->  [String: Any]
    
}

extension BeeJSON {
    
    static func defaultValues() ->  [String: Any] {
        return [:]
    }
    
}


