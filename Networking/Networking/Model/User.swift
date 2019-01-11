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
    public var fullName: String?
    public var uid: String?
    public var provider: String?
    public var isAdmin: Bool
    public var isModerator: Bool
    public var cluster: ClusterDetail?
    public var votePreference: Int?
    public var verified: Bool
    public var avatar: Avatar
    public var username: String?
    public var about: String?
    public var location: String?
    public var education: String?
    public var occupation: String?
    public var informant: Informant?
    
    private enum CodingKeys: String, CodingKey {
        case id
        case email
        case fullName = "full_name"
        case uid
        case provider
        case isAdmin = "is_admin"
        case isModerator = "is_moderator"
        case cluster
        case votePreference = "vote_preference"
        case verified
        case avatar
        case username
        case about
        case location
        case education
        case occupation
        case informant
    }
    
}
