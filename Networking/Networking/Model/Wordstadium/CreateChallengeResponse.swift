//
//  CreateChallengeResponse.swift
//  Networking
//
//  Created by Hanif Sugiyanto on 23/02/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

public struct CreateChallengeResponse: Codable {
    
    public let challenge: Challenge
    
}

public struct Challenge: Codable {
    public let id: String
    public let type: String
    public let source: String?
    public let statement: String?
    public let showTimeAt: String?
    public let timeLimit: Int?
    public let progress: String?
    public let condition: String?
    public let topic: [String]?
    public let createdAt: String?
    public let audiences: [Audiences]?
    
    private enum CodingKeys: String, CodingKey {
        case id, type, statement, progress, condition, audiences
        case source = "statement_source"
        case showTimeAt = "show_time_at"
        case timeLimit = "time_limit"
        case topic = "topic_list"
        case createdAt = "created_at"
    }
    
}

public struct Audiences: Codable {
    public let id: String
    public let role: String?
    public let userId: String?
    public let email: String?
    public let fullName: String?
    public let username: String?
    public let avatar: Avatar?
    public let about: String?
    
    private enum CodingKeys: String, CodingKey {
        case id, role, email, avatar, about, username
        case userId = "user_id"
        case fullName = "full_name"
    }
}
