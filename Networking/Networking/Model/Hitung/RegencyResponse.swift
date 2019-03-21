//
//  RegencyResponse.swift
//  Networking
//
//  Created by Nanang Rafsanjani on 18/03/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import Foundation

public struct RegencyResponse: Codable {
    public let regencies: [Regency]
    public let meta: Meta
    
    private enum CodingKeys: String, CodingKey {
        case regencies = "regencies"
        case meta = "meta"
    }
}
