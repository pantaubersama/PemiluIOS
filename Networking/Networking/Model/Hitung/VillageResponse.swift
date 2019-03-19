//
//  VillageResponse.swift
//  Networking
//
//  Created by Nanang Rafsanjani on 19/03/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import Foundation

public struct VillageResponse: Codable {
    public let villages: [Village]
    public let meta: Meta
    
    private enum CodingKeys: String, CodingKey {
        case villages = "villages"
        case meta = "meta"
    }
}
