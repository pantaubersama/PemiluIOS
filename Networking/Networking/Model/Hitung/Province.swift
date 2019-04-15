//
//  Province.swift
//  Networking
//
//  Created by Nanang Rafsanjani on 13/03/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import Foundation

public struct Province: Codable {
    public let id: Int
    public let code: Int
    public var name: String
    public let level: Int
    public let domainName: String
    public let idWilayah: Int
    
    private enum CodingKeys: String, CodingKey {
        case id = "id"
        case code = "code"
        case name = "name"
        case level = "level"
        case domainName = "domain_name"
        case idWilayah = "id_wilayah"
    }
}
