//
//  Word.swift
//  Networking
//
//  Created by Rahardyan Bisma Setya Putra on 06/03/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import Foundation

// To parse the JSON, add this file to your project and do:
//
//   let word = try? newJSONDecoder().decode(Word.self, from: jsonData)

import Foundation

public struct Word: Codable {
    public let id, type, challengeID, body: String
    public let readTime, timeSpent, timeLeft: Int
    public let createdAt: String
    public let author: Author
    
    enum CodingKeys: String, CodingKey {
        case id, type
        case challengeID = "challenge_id"
        case body
        case readTime = "read_time"
        case timeSpent = "time_spent"
        case timeLeft = "time_left"
        case createdAt = "created_at"
        case author
    }
}

public struct Author: Codable {
    public let id, email, fullName, username: String
    public let avatar: Avatar
    public let about: String
    
    enum CodingKeys: String, CodingKey {
        case id, email
        case fullName = "full_name"
        case username, avatar, about
    }
}
