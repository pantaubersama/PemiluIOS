//
//  RealCountPostRequest.swift
//  Networking
//
//  Created by Hanif Sugiyanto on 28/03/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import Foundation

public struct RealCountPostRequest: Codable {
    
    public let status: Bool
    public let realCount: RealCount
 
    private enum CodingKeys: String, CodingKey {
        case status
        case realCount = "real_count"
    }
    
}
