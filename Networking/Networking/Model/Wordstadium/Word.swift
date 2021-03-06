//
//  Word.swift
//  Networking
//
//  Created by Rahardyan Bisma Setya Putra on 06/03/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

// To parse the JSON, add this file to your project and do:
//
//   let word = try? newJSONDecoder().decode(Word.self, from: jsonData)

import Foundation
import RxDataSources

public struct Word: Codable {
    public let id, type, challengeID, body: String
    public let readTime, timeSpent, timeLeft: Double?
    public let createdAt: String
    public let author: Author
    public var clapCount: Int?
    public var isClapped: Bool?
    
    enum CodingKeys: String, CodingKey {
        case id, type
        case challengeID = "challenge_id"
        case body
        case readTime = "read_time"
        case timeSpent = "time_spent"
        case timeLeft = "time_left"
        case createdAt = "created_at"
        case author
        case clapCount = "clap_count"
        case isClapped = "is_clap"
    }
}

public struct Author: Codable {
    public let id, email, fullName, username: String
    public let avatar: Avatar
    public let about: String?
    private let roleString: String
    
    enum CodingKeys: String, CodingKey {
        case id, email
        case roleString = "role"
        case fullName = "full_name"
        case username, avatar, about
    }
}

extension Author {
    public var role: AudienceRole {
        return AudienceRole(rawValue: roleString) ?? AudienceRole.challenger
    }
}

extension Word: IdentifiableType {
    public typealias Identity = String
    
    public var identity: Identity { return id }
}

extension Word: Equatable { }

public func == (lhs: Word, rhs: Word) -> Bool {
    return lhs.id == rhs.id
}
