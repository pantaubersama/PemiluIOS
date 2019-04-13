//
//  CandidateResponse.swift
//  Networking
//
//  Created by Hanif Sugiyanto on 29/03/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import Foundation
import RxDataSources

public struct CandidateResponse: Codable {
    public let id: Int
    public let serialNumber: Int
    public let name: String
    public let acronym: String
    public let logo: Avatar?
    public let actorType: String?
    public let candidates: [Candidates]
    
    private enum CodingKeys: String, CodingKey {
        case id, name, logo, candidates, acronym
        case serialNumber = "serial_number"
        case actorType = "actor_type"
    }
    
}

public struct Candidates: Codable {
    public let actorType: String?
    public let id: Int
    public let name: String?
    public let gender: String?
    public let serialNumber: Int
    public let dapil: Dapil
    public let politicalParty: Party?
    
    private enum CodingKeys: String, CodingKey {
        case id, name, gender, dapil
        case actorType = "actor_type"
        case serialNumber = "serial_number"
        case politicalParty = "political_party"
    }
}


public struct Dapil: Codable {
    public let id: Int
    public let nama: String?
    public let tingkat: String?
}


public struct Party: Codable {
    public let id: Int
    public let serialNumber: Int
    public let name: String
    public let acronym: String
    public let logo: Avatar?
    
    private enum CodingKeys: String, CodingKey {
        case id, name, acronym, logo
        case serialNumber = "serial_number"
    }
}

extension CandidateResponse: IdentifiableType {
    public typealias Identity = Int
    public var identity: Identity { return id }
}

extension CandidateResponse: Equatable { }

public func == (lhs: CandidateResponse, rhs: CandidateResponse) -> Bool {
    return lhs.id == rhs.id
}
