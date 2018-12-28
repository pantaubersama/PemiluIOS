//
//  User.swift
//  Networking
//
//  Created by Hanif Sugiyanto on 28/12/18.
//  Copyright © 2018 PantauBersama. All rights reserved.
//

import Foundation

public struct User: Codable {
    
    public let id: String
    public var email: String
    public var firstName: String?
    public var lastName: String?
    public var uid: String?
    public var provider: String?
    public var isAdmin: Bool
    public var isModerator: Bool
    public var cluster: Cluster?
    public var votePreference: Int?
    
    private enum CodingKeys: String, CodingKey {
        case id
        case email
        case firstName = "first_name"
        case lastName = "last_name"
        case uid
        case provider
        case isAdmin = "is_admin"
        case isModerator = "is_moderator"
        case cluster
        case votePreference = "vote_preference"
    }
    
}


public struct Cluster: Codable {
    
}
