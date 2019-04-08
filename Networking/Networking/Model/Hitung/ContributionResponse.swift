//
//  ContributionResponse.swift
//  Networking
//
//  Created by Hanif Sugiyanto on 05/04/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import Foundation

public struct ContributionResponse: Codable {
    
    public let total: Int
    public let lastUpdate: LastUpdate
    
    private enum CodingKeys: String, CodingKey {
        case total
        case lastUpdate = "last_update"
    }
}

public struct LastUpdate: Codable {
    public let createdAt: String
    public let createdInWord: CreatedInWord
    
    private enum CodingKeys: String, CodingKey {
        case createdAt = "created_at"
        case createdInWord = "created_at_in_word"
    }
}

public struct CreatedInWord: Codable {
    public let timeZone: String
    public let iso8601: String
    public let en: String
    public let id: String
    
    private enum CodingKeys: String, CodingKey {
        case en, id
        case timeZone = "time_zone"
        case iso8601 = "iso_8601"
    }
}
