//
//  UserPantau.swift
//  Networking
//
//  Created by wisnu bhakti on 03/01/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import Foundation

public struct UserPantau: Codable {
    
    public let id: String
    public var email: String
    public var fullName: String
    
    
    private enum CodingKeys: String, CodingKey {
        case id
        case email
        case fullName = "full_name"
    } 
}
