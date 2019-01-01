//
//  JanjiPolitik.swift
//  Networking
//
//  Created by wisnu bhakti on 01/01/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import Foundation

public struct UserJanpol: Codable {
    
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
    
}

public struct Image: Codable {
    public var url: String?
    public var small: Url?
    public var medium: Url?
    public var large: Url?
    
    public struct Url: Codable {
        public var url: String?
    }
    
    private enum CodingKeys: String, CodingKey {
        case url
        case small
        case medium
        case large
    }
    
}

public struct JanjiPolitik: Codable {
    
    public let id: String
    public var title: String
    public var body: String
    public var image: Image
    public var createdAt: String
    public var user: UserJanpol
    
    enum CodingKeys: String, CodingKey {
        case id, title, body, image, user
        case createdAt = "created_at"
    }
    
}
