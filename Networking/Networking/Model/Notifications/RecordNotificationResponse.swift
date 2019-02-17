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
    public let data: NotifData
    
    private enum CodingKeys: String, CodingKey {
        case id, notification, data
        case isAction = "is_action"
    }
}

public struct NotifData: Codable {
    public let payload: NotifPayload?
}

public struct NotifPayload: Codable {
    public let notifType: String
    public let eventType: String
    public let quiz: NotifQuiz?
    public let broadcast: Broadcast?
    public let badge: NotifBadge?
    public let question: Question?
    
    private enum CodingKeys: String, CodingKey {
        case notifType = "notif_type"
        case eventType = "event_type"
        case quiz, badge, question
        case broadcast = "pemilu_broadcast"
    }
}
