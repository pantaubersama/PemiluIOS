//
//  SummaryProvinceResponse.swift
//  Networking
//
//  Created by Hanif Sugiyanto on 05/04/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import Foundation

public struct SummaryProvinceResponse: Codable {
    public let region: Region?
    public let percentages: [SimpleSummary]
}

public struct SimpleSummary: Codable {
    public let percentage: Percentage?
    public let region: Region?
}


public struct Percentage: Codable {
    public let region: Region?
    public let type: String?
    public let candidates: [CandidateSummary]?
    public let invalidVote: InvalidSummary
    public let totalVote: Int
    
    private enum CodingKeys: String, CodingKey {
        case candidates, region
        case type = "summary_type"
        case invalidVote = "invalid_vote"
        case totalVote = "total_vote"
    }
}

