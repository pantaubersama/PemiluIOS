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
    public static let dateTimeFormat3 = "YYYY-MM-dd'T'HH:mm:ss.SSSZ"
    public static let dateTimeFormat4 = "HH:mm, dd MMMM YYYY"
    public static let dateFormat = "yyyy-MM-dd"
    public static let timeFormat = "HH:mm"
    public static let monthFormat = "MMMM"
}

extension String {
    public static var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = Constant.dateTimeFormat
        formatter.locale = Locale.current
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        return formatter
    }()
    
    public static var dateFormatter3: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = Constant.dateTimeFormat3
        formatter.locale = Locale.current
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        return formatter
    }()
    
    public var date: String? {
        guard  let date = String.dateFormatter.date(from: self)?.toString(format: Constant.dateFormat) else {
            return String.dateFormatter3.date(from: self)?.toString(format: Constant.dateFormat)
        }
        return date
    }
    
    public var time: String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = Constant.dateTimeFormat
        
        let dt = dateFormatter.date(from: self)
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        dateFormatter.dateFormat = "h:mm a"
        return dateFormatter.string(from: dt!)
    }
    
    public func toDate(format: String = Constant.dateTimeFormat) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.date(from: self)
    }
    
    public var timeAgoSinceDate: String {
        guard let date = self.toDate() else { return self }
        let calendar = Calendar.current
        let now = Date()
        let earliest = (date < now ) ? date : now
        let latest = (earliest == now) ? date : now
        
        let components:DateComponents = calendar.dateComponents([ .day, .hour, .minute, .second], from: earliest, to: latest)
        
        let day = components.day ?? 0
        let hour = components.hour ?? 0
        let minute = components.minute ?? 0
        let second = components.second ?? 0
        
        if (day >= 2) {
            return date.toString(format: Constant.dateTimeFormat4)
        } else if (day >= 4){
            return "4 day ago"
        }else if (day >= 3){
            return "3 day ago"
        }else if (day >= 2){
            return "2 day ago"
        }else if (day >= 1){
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
        
        if (day >= 5) {
            return self.toString()
        }
        else if (day >= 4){
            return "4 day ago"
        }else if (day >= 3){
            return "3 day ago"
        }else if (day >= 2){
            return "2 day ago"
        }else if (day >= 1){
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



