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

public struct Cluster: Codable {
    public let id: String
    public var name: String?
    public var isEligible: Bool
    public var image: Avatar
    
    private enum CodingKeys: String, CodingKey {
        case id
        case name
        case isEligible = "is_eligible"
        case image
    }
}


public struct Clusters: Codable {
    public let clusters: [ClusterDetail]
    public let meta: Meta
}


public struct ClusterDetail: Codable {
    public let id: String
    public let name: String
    public let image: Avatar
    public let isDisplayed: Bool?
    public let categoryId: String?
    public let category: Category?
    public let description: String?
    public let memberCount: Int
    public let isEligible: Bool?
    public let magicLink: String?
    public let isLinkActive: Bool?
    public let status: String?
    
    private enum CodingKeys: String, CodingKey {
        case id
        case name
        case image
        case isDisplayed = "is_displayed"
        case categoryId = "category_id"
        case category
        case description
        case memberCount = "members_count"
        case isEligible = "is_eligible"
        case magicLink = "magic_link"
        case isLinkActive = "is_link_active"
        case status
    }
}

public struct SingleCluster: Codable {
    public let cluster: ClusterDetail
}

public struct DeleteCluster: Codable {
    public let status: Bool
    public let cluster: ClusterDetail
}
