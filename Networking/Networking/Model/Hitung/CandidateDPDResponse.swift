//
//  CandidateDPDResponse.swift
//  Networking
//
//  Created by Hanif Sugiyanto on 11/04/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import Foundation

public struct CandidateDPDResponse: Codable {
    public let id: Int
    public let nama: String
    public let type: String
    public let tingkat: String
    public let candidates: [CandidatesDPD]
    
    private enum CodingKeys: String, CodingKey {
        case id, nama, tingkat, candidates
        case type = "actor_type"
    }
    
}


public struct CandidatesDPD: Codable {
    public let id: Int
    public let name: String
    public let number: Int
    public let type: String
    public let dapil: Dapil
    
    private enum CodingKeys: String, CodingKey {
        case id, name, dapil
        case type = "actor_type"
        case number = "serial_number"
    }
}
