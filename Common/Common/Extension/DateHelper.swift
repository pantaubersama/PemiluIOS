//
//  DateHelper.swift
//  Common
//
//  Created by Hanif Sugiyanto on 01/01/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import Foundation

public class Constant {
    public static let dateTimeFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
    public static let dateTimeFormat2 = "yyyy-MM-dd HH:mm:ss"
    public static let dateTimeFormat3 = "YYYY-MM-dd'T'HH:mm:ss.sssZ"
    public static let dateTimeFormat4 = "HH:mm, dd MMMM YYYY"
    public static let dateFormat = "yyyy-MM-dd"
    public static let timeFormat = "HH:mm"
    public static let monthFormat = "MMMM"
}

extension Date {
    public func toString(format: String = Constant.dateFormat) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: self)
    }
    
    public var timeAgoSinceDate: String {
        let calendar = Calendar.current
        let now = Date()
        let earliest = (self < now ) ? self : now
        let latest = (earliest == now) ? self : now
        
        let components: DateComponents = calendar.dateComponents([.day], from: earliest, to: latest)
        
        let day = components.day ?? 0
        
        if (day >= 2) {
            return self.toString()
        } else if (day >= 1){
            return "Kemarin"
        } else {
            return "Hari ini"
        }
    }
    
    public var timeAgoSinceDate2: String {
        let calendar = Calendar.current
        let now = Date()
        let earliest = (self < now ) ? self : now
        let latest = (earliest == now) ? self : now
        
        let components:DateComponents = calendar.dateComponents([ .day, .hour, .minute, .second], from: earliest, to: latest)
        
        let day = components.day ?? 0
        let hour = components.hour ?? 0
        let minute = components.minute ?? 0
        let second = components.second ?? 0
        
        if (day >= 2) {
            return self.toString()
        } else if (day >= 1){
            return "1 day ago"
        } else if (hour >= 2) {
            return "\(hour) hours ago"
        } else if (hour >= 1){
            return "1 hour ago"
        } else if (minute >= 2) {
            return "\(minute) minutes ago"
        } else if (minute >= 1){
            return "1 minute ago"
        } else if (second >= 3) {
            return "\(second) seconds ago"
        } else {
            return "Just now"
        }
    }
}



