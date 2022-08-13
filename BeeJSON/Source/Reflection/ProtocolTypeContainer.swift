//
//  ProtocolTypeContainer.swift
//  BeeJSON
//
//  Created by snow on 2022/8/9.
//

import Swift

@usableFromInline internal struct ProtocolTypeContainer {
    let type: Any.Type
    let witnessTable = 0
    
    @usableFromInline internal init(type: Any.Type) {
        self.type = type
    }
}
