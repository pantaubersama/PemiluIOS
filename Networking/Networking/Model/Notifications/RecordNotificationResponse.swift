//
//  RecordNotificationResponse.swift
//  Networking
//
//  Created by Hanif Sugiyanto on 01/02/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import Foundation

public struct RecordNotificationResponse: Codable {
    
    public let notifications: [NotificationRecord]
    
}

public struct NotificationRecord: Codable {
    public let id: String?
    public let notification: Notif?
    public let isAction: Bool?
    public let data: Broadcast?
    
    private enum CodingKeys: String, CodingKey {
        case id, notification, data
        case isAction = "is_action"
    }
}
