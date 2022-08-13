//
//  ISO8601DateTransform.swift
//  BeeJSON
//
//  Created by snow on 2022/8/13.
//

import Foundation

public extension DateFormatter {
    convenience init(withFormat format : String, locale : String) {
        self.init()
        self.locale = Locale(identifier: locale)
        dateFormat = format
    }
}

open class ISO8601DateTransform: DateFormatterTransform {
    
    static let reusableISODateFormatter = DateFormatter(withFormat: "yyyy-MM-dd'T'HH:mm:ssZZZZZ", locale: "en_US_POSIX")

    public init() {
        super.init(dateFormatter: ISO8601DateTransform.reusableISODateFormatter)
    }
}
