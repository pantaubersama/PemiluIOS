//
//  QuestionResponse.swift
//  Networking
//
//  Created by Rahardyan Bisma on 27/12/18.
//  Copyright © 2018 PantauBersama. All rights reserved.
//

import Foundation

public struct QuestionResponse: Codable {
    public let data: DataClass
    
    public struct DataClass: Codable {
        public let status: Bool
        public let question: Question
    }
}

public struct QuestionsResponse: Codable {
    public let data: DataClass
    
    public struct DataClass: Codable {
        public let questions: [Question]
        public let meta: Meta
        
        public struct Meta: Codable {
            public let pages: Pages
            
            public struct Pages: Codable {
                public let total, perPage, page: Int
                
                enum CodingKeys: String, CodingKey {
                    case total
                    case perPage = "per_page"
                    case page
                }
            }
        }
    }
}

public struct Question: Codable {
    public let id, body: String
    public let createdAt: CreatedAt
    public let created: String
    public let likeCount: Int
    public let user: Creator
    
    enum CodingKeys: String, CodingKey {
        case id, body
        case createdAt = "created_at"
        case created
        case likeCount = "like_count"
        case user
    }
}

public struct CreatedAt: Codable {
    public let iso8601, en, id: String
    
    enum CodingKeys: String, CodingKey {
        case iso8601 = "iso_8601"
        case en, id
    }
}

public struct Creator: Codable {
    public let id, email, firstName, lastName: String
    public let username: String?
    public let avatar: Avatar
    public let verified: Bool
    public let about: String?
    
    enum CodingKeys: String, CodingKey {
        case id, email
        case firstName = "first_name"
        case lastName = "last_name"
        case username, avatar, verified, about
    }
    
    public struct Avatar: Codable {
        public let url: String?
        public let thumbnail, thumbnailSquare, medium, mediumSquare: ImageSize
        
        enum CodingKeys: String, CodingKey {
            case url, thumbnail
            case thumbnailSquare = "thumbnail_square"
            case medium
            case mediumSquare = "medium_square"
        }
        
        public struct ImageSize: Codable {
            public let url: String?
        }
    }
}

