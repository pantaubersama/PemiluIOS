//
//  Feed.swift
//  Networking
//
//  Created by wisnu bhakti on 31/12/18.
//  Copyright © 2018 PantauBersama. All rights reserved.
//

public struct Team: Codable {
    public let id: Int
    public let title: String
    public let avatar: String?
}

public struct Source: Codable {
    public let id: String
    public let text: String
}

public struct Account: Codable {
    public let id: String
    public let name: String
    public let username: String
    public let profileImageUrl: String?
    
    enum CodingKeys: String, CodingKey {
        case id, name, username
        case profileImageUrl = "profile_image_url"
    }
}

public struct Feeds: Codable {
    
    public let id: String
    public var team: Team
    public var createdAt: String
    public var source: Source
    public var account: Account
    
    enum CodingKeys: String, CodingKey {
        case id, team, source, account
        case createdAt = "created_at"
    }
    
}

