//
//  Village.swift
//  Networking
//
//  Created by Nanang Rafsanjani on 19/03/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import Foundation

public struct Village: Codable {
    public let id: Int
    public let code: Int
    public let districtCode: Int
    public let name: String
    
    private enum CodingKeys: String, CodingKey {
        case id = "id"
        case code = "code"
        case districtCode = "district_code"
        case name = "name"
    }
}
