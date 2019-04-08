//
//  SummaryPresidentResponse.swift
//  Networking
//
//  Created by Hanif Sugiyanto on 05/04/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import Foundation

public struct SummaryPresidentResponse: Codable {
    public let tps: Int?
    public let user: User?
    public let percentage: SummaryPercentage?
}


public struct SummaryPercentage: Codable {
    public let region: Region?
    public let summaryType: String?
    public let candidates: [CandidateSummary]?
    public let invalidVote: InvalidSummary
    public let totalVote: Int
    
    private enum CodingKeys: String, CodingKey {
        case region, candidates
        case summaryType = "summary_type"
        case invalidVote = "invalid_vote"
        case totalVote = "total_vote"
    }
}


public struct Region: Codable {
    public let id: Int
    public let code: Int
    public let name: String
    public let level: Int
    public let createdAt: String
    public let updatedAt: String
    
    private enum CodingKeys: String, CodingKey {
        case id, code, name, level
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}


public struct CandidateSummary: Codable {
    public let id: Int
    public let totalVote: Int
    public let percentage: Double
    
    private enum CodingKeys: String, CodingKey {
        case id, percentage
        case totalVote = "total_vote"
    }
}


public struct InvalidSummary: Codable {
    public let totalVote: Int
    public let percentage: Double
    
    private enum CodingKeys: String, CodingKey {
        case totalVote = "total_vote"
        case percentage
    }
}
