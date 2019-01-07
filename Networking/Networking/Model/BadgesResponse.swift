//
//  BadgesResponse.swift
//  Networking
//
//  Created by Hanif Sugiyanto on 30/12/18.
//  Copyright © 2018 PantauBersama. All rights reserved.
//

import Foundation

public struct BadgesResponse: Codable {
    
    public var achieved: [AchievedResponse]
    public var badges: [Badges]
    public let meta: Meta
    
    public struct Meta: Codable {
        public let pages: Pagination
        
        public struct Pagination: Codable {
            public let total: Int
            public let perPage: Int?
            public let page: Int
            
            private enum CodingKeys: String, CodingKey {
                case total
                case perPage = "per_page"
                case page
            }
        }
    }
    
    private enum CodingKeys: String, CodingKey {
        case achieved = "achieved_badges"
        case badges
        case meta
    }
    
}


public struct Badges: Codable {
    
    public let id: String
    public var name: String?
    public var description: String?
    public var image: Avatar
    public var position: Int
    
    
    public struct Avatar: Codable {
        public let url: String?
        public let thumbnail, thumbnailSquare: ImageSize

        enum CodingKeys: String, CodingKey {
            case url, thumbnail
            case thumbnailSquare = "thumbnail_square"
        }

        public struct ImageSize: Codable {
            public let url: String?
        }
    }
}


public struct AchievedResponse: Codable {
    public let id: String
    public let badge: Badges
    public let user: UserMinimal?
    
    enum CodingKeys: String, CodingKey {
        case id = "achieved_id"
        case badge
        case user
    }
    
    public struct UserMinimal: Codable {
        public let id: String
        public let email: String?
        public let fullName: String?
        public let username: String?
        public let avatar: Avatar?
        public let verified: Bool
        public let about: String?
        
        private enum CodingKeys: String, CodingKey {
            case id
            case email
            case fullName = "full_name"
            case username
            case avatar
            case verified
            case about
        }
        
    }
}
