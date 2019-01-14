//
//  UsersResponse.swift
//  Networking
//
//  Created by Rahardyan Bisma Setya Putra on 14/01/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import Foundation

// To parse the JSON, add this file to your project and do:
//
//   let usersResponse = try? newJSONDecoder().decode(UsersResponse.self, from: jsonData)

import Foundation

public struct UsersResponse: Codable {
    public let data: DataClass
    
    public struct DataClass: Codable {
        public let users: [User]
        public let meta: Meta
    }
    
    public struct Meta: Codable {
        public let pages: Pages
    }
    
    public struct Pages: Codable {
        public let total, perPage, page: Int
        
        enum CodingKeys: String, CodingKey {
            case total
            case perPage = "per_page"
            case page
        }
    }

}

