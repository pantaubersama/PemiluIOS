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
    public var firstName: String
    public var lastName: String
    
    
    private enum CodingKeys: String, CodingKey {
        case id
        case email
        case firstName = "first_name"
        case lastName = "last_name"
    }
    
    public var fullname: String? {
        return firstName + " " + lastName
    }
}
