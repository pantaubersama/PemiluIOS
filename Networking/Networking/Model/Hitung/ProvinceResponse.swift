//
//  ProvinceResponse.swift
//  Networking
//
//  Created by Nanang Rafsanjani on 18/03/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import Foundation

public struct ProvinceResponse: Codable {
    public let provinces: [Province]
    public let meta: Meta
    
    private enum CodingKeys: String, CodingKey {
        case provinces = "provinces"
        case meta = "meta"
    }
}
