//
//  FirebaseBroadcastResponse.swift
//  Networking
//
//  Created by Hanif Sugiyanto on 29/01/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import Foundation

public struct FirebaseBroadcastResponse: Codable {
    
    public var notification: Notif
    public var broadcast: Broadcast
    
    public struct Broadcast: Codable {
        public let id: String
        public let title: String?
        public let description: String?
        public let eventType: String?
        public let link: String?
        
        private enum CodingKeys: String, CodingKey {
            case id, title, description, link
            case eventType = "event_type"
        }
    }
    
    private enum CodingKeys: String, CodingKey {
        case notification
        case broadcast = "pemilu_broadcast"
    }
    
}


public struct Notif: Codable {
    public let title: String?
    public let body: String?
}
