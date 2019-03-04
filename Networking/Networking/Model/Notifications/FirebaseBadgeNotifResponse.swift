//
//  FirebaseBadgeNotifResponse.swift
//  Networking
//
//  Created by Rahardyan Bisma on 11/02/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import Foundation

public struct FirebaseBadgeNotifResponse: Codable {
    public var notification: Notif
    public var achievedBadge: AchievedBadge
    
    private enum CodingKeys: String, CodingKey {
        case notification
        case achievedBadge = "achieved_badge"
    }
    
}

public struct AchievedBadge: Codable {
    public var achievedId: String
    public var badge: NotifBadge
    
    private enum CodingKeys: String, CodingKey {
        case badge
        case achievedId = "achieved_id"
    }
}

// TODO: Minta backend utk menyamakan format image size
// biar bisa pakai 1 model struct aja
// yang lain {thumbnail: { url: "http://image"}
// yang ini {thumbnail: "http://image"}

public struct NotifBadge: Codable {
    public var id: String
    public var image: NotifBadgeImage?
    
    private enum CodingKeys: String, CodingKey {
        case id, image
    }
}

public struct NotifBadgeImage: Codable {
    public var thumbnail: String?
    public var thumbnailSquare: String?
    
    private enum CodingKeys: String, CodingKey {
        case thumbnail
        case thumbnailSquare = "thumbnail_square"
    }
}
