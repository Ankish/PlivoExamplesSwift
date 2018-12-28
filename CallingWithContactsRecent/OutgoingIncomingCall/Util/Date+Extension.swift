//
//  Date+Extension.swift
//  OutgoingIncomingCall
//
//  Created by Plivo on 12/28/18.
//  Copyright © 2018 Plivo. All rights reserved.
//

import Foundation

extension Date {
    
    var monthDateYear : String {
        return Formatter.formatter("dd MMM, yyyy , hh:mm a").string(from: self)
    }
}

extension Formatter {
    static func formatter(_ format : String) -> DateFormatter  {
        let formatter = DateFormatter()
        let localeStr = "en_US_POSIX"
        formatter.locale = Locale(identifier: localeStr)
        formatter.dateFormat = format
        return formatter
    }
}
