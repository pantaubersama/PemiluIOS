//
//  ClusterResponse.swift
//  Networking
//
//  Created by Hanif Sugiyanto on 11/01/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import Foundation


// TODO : All cluster response in Microservice
// you can use this kind of model
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
    public let id: String?
    public let name: String?
    public let image: Avatar?
    public let isDisplayed: Bool?
    public let categoryId: String?
    public let category: Category?
    public let description: String?
    public let memberCount: Int?
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

extension ClusterDetail {
    public var memberCountString: String {
        return "\(self.memberCount ?? 0) anggota"
    }
}
// this model jus for single
public struct SingleCluster: Codable {
    public let cluster: ClusterDetail
}
// mapping cluster delete
public struct DeleteCluster: Codable {
    public let status: Bool
    public let cluster: ClusterDetail
}

// Mapping cluster invite
public struct ClusterInvite: Codable {
    public let id: String
    public let email: String
    public let status: String
}
