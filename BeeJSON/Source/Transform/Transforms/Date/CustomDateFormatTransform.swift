//
//  CustomDateFormatTransform.swift
//  BeeJSON
//
//  Created by snow on 2022/8/13.
//

import Foundation

open class CustomDateFormatTransform: DateFormatterTransform {
    
    public init(formatString: String) {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = formatString
        
        super.init(dateFormatter: formatter)
    }
}
