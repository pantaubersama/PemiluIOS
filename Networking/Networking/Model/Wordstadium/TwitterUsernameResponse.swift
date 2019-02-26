//
//  TwitterUsernameResponse.swift
//  Networking
//
//  Created by Hanif Sugiyanto on 25/02/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import Foundation

public struct TwitterUsernameResponses: Codable {
    
    public let users: [TwitterUsername]
    
}

public struct TwitterUsername: Codable {
    public let id: Int
    public let name: String?
    public let screenName: String?
    public let profileImage: String?
    
    private enum CodingKeys: String, CodingKey {
        case id, name
        case screenName = "screen_name"
        case profileImage = "profile_image_url"
    }
}
