//
//  RealCountResponse.swift
//  Networking
//
//  Created by Hanif Sugiyanto on 28/03/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import Foundation

public struct RealCountResponse: Codable {
    public let status: Bool?
    public let calculation: Calculation
}


public struct Calculation: Codable {
    
    public let realCountId: String
    public let realCount: RealCount
    public let calculationType: String
    public let id: String
    public let invalidVote: Int
    public let createAtInWord: CreatedAt
    public let candidates: [ItemActor]?
    public let parties: [ItemActor]?
    
    private enum CodingKeys: String, CodingKey {
        case candidates, parties, id
        case realCountId = "hitung_real_count_id"
        case realCount = "real_count"
        case calculationType = "calculation_type"
        case invalidVote = "invalid_vote"
        case createAtInWord = "created_at_in_word"
    }
}

public struct ItemActor: Codable {
    public let actorId: String?
    public let actorType: String?
    public let totalVote: Int?
    
    private enum CodingKeys: String, CodingKey {
        case actorId = "actor_id"
        case actorType = "actor_type"
        case totalVote = "total_vote"
    }
}


// Object to save candidates in presiden real count
public struct CandidatesCount: Codable {
    public var id: Int
    public var totalVote: Int
    
    public init(id: Int, totalVote: Int) {
        self.id = id
        self.totalVote = totalVote
    }
    
    private enum CodingKeys: String, CodingKey {
        case id
        case totalVote = "total_vote"
    }
}
