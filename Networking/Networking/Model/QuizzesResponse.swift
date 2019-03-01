//
//  QuizzesResponse.swift
//  Networking
//
//  Created by Rahardyan Bisma on 03/01/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

// To parse the JSON, add this file to your project and do:
//
//   let quizzesResponse = try? newJSONDecoder().decode(QuizzesResponse.self, from: jsonData)

import Foundation

public struct QuizzesResponse: Codable {
    public let data: DataClass
    
    public struct DataClass: Codable {
        public let quizzes: [Quiz]
        let meta: Meta
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

public struct Quiz: Codable {
    public let id, title, description: String
    public let image: Image?
    public let quizQuestionsCount: Int
    public let createdAt: String
    public let createdAtInWord: CreatedAt
    public let participationStatus: String
    public let shareURL: String
    
    enum CodingKeys: String, CodingKey {
        case id, title, description, image
        case quizQuestionsCount = "quiz_questions_count"
        case createdAt = "created_at"
        case createdAtInWord = "created_at_in_word"
        case participationStatus = "participation_status"
        case shareURL = "share_url"
    }
    
    public struct CreatedAt: Codable {
        public let iso8601, en, id: String
        
        enum CodingKeys: String, CodingKey {
            case iso8601 = "iso_8601"
            case en, id
        }
    }
    
    public struct Image: Codable {
        public let url: String?
        public let thumbnail, thumbnailSquare, large, largeSquare: ImageSize?
        
        enum CodingKeys: String, CodingKey {
            case url, thumbnail
            case thumbnailSquare = "thumbnail_square"
            case large
            case largeSquare = "large_square"
        }
    }
    
    public struct ImageSize: Codable {
        public let url: String?
    }
}

public struct SingleQuizResponse: Codable {
    public let quiz: Quiz
}
