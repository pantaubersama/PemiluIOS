//
//  WordNotifResponse.swift
//  Networking
//
//  Created by Hanif Sugiyanto on 13/03/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import Foundation

public struct WordNotifResponse: Codable {
    
    public let notification: Notif
    public let eventType: String
    public let notifType: String
    public let word: Word
    
    private enum CodingKeys: String, CodingKey {
        case notification, word
        case eventType = "event_type"
        case notifType = "notif_type"
    }
    
}
