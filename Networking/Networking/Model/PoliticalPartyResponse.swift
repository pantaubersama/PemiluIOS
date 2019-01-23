//
//  PoliticalPartyResponse.swift
//  Networking
//
//  Created by Hanif Sugiyanto on 23/01/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import Foundation

public struct PoliticalPartyResponse: Codable {
    
    public let politicalParty: [PoliticalParty]
    public let meta: Meta
    
    private enum CodingKeys: String, CodingKey {
        case politicalParty = "political_parties"
        case meta
    }

}

public struct PoliticalParty: Codable {
    
    public let id: String
    public let name: String
    public let image: Avatar
    public let number: Int
}
