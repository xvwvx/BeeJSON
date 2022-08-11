//
//  ProtocolTypeContainer.swift
//  BeeJSON
//
//  Created by snow on 2022/8/9.
//

import Swift

internal struct ProtocolTypeContainer {
    let type: Any.Type
    let witnessTable = 0
    
    var anyExtension: AnyExtension.Type {
        unsafeBitCast(self, to: AnyExtension.Type.self)
    }
}
