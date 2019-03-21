//
//  DistrictResponse.swift
//  Networking
//
//  Created by Nanang Rafsanjani on 18/03/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import Foundation

public struct DistrictResponse: Codable {
    public let districts: [District]
    public let meta: Meta
    
    private enum CodingKeys: String, CodingKey {
        case districts = "districts"
        case meta = "meta"
    }
}
