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
    public let createdAt: NotifCreatedAt
    
    private enum CodingKeys: String, CodingKey {
        case id, notification, data
        case isAction = "is_action"
        case createdAt = "created_at_in_word"
    }
}

public struct NotifCreatedAt: Codable {
    public let timeZone: String
    public let en: String
    public let id: String
    
    private enum CodingKeys: String, CodingKey {
        case timeZone = "time_zone"
        case en, id
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
    public let badge: AchievedBadge?
    public let question: NotifQuestion?
    
    private enum CodingKeys: String, CodingKey {
        case notifType = "notif_type"
        case eventType = "event_type"
        case quiz, question
        case badge = "achieved_badge"
        case broadcast = "pemilu_broadcast"
    }
}

public struct NotifQuestion: Codable {
    public let id: String
    public let avatar: NotifQuestionAvatar?
}

public struct NotifQuestionAvatar: Codable {
    public let thumbnail: String
    public let large: String
}
