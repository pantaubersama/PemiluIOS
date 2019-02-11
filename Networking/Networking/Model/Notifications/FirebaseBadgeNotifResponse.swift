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
    public var badge: NotifBadge
    
    private enum CodingKeys: String, CodingKey {
        case notification, badge
    }
    
    // TODO: Minta backend utk menyamakan format image size
    // biar bisa pakai 1 model struct aja
    // yang lain {thumbnail: { url: "http://image"}
    // yang ini {thumbnail: "http://image"}
    public struct NotifBadge: Codable {
        public var id: String
    }
}
