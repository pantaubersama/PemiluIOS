//
//  District.swift
//  Networking
//
//  Created by Nanang Rafsanjani on 13/03/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import Foundation

public struct District: Codable {
    public let id: Int
    public let code: Int
    public let regencyCode: Int
    public var name: String
    public let idParent: Int
    public let idWilayah: Int
    public let level: Int
    
    private enum CodingKeys: String, CodingKey {
        case id = "id"
        case code = "code"
        case regencyCode = "regency_code"
        case name = "name"
        case idParent = "id_parent"
        case idWilayah = "id_wilayah"
        case level = "level"
    }
}
