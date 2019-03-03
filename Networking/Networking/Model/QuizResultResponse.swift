//
//  QuizResultResponse.swift
//  Networking
//
//  Created by Rahardyan Bisma on 06/01/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

// To parse the JSON, add this file to your project and do:
//
//   let quizResultResponse = try? newJSONDecoder().decode(QuizResultResponse.self, from: jsonData)

import Foundation

public struct QuizResultResponse: Codable {
    public let data: DataClass
    
    public struct DataClass: Codable {
        public let shareURL: String?
        public let teams: [TeamElement]
        public let answers: [Int]
        public let quiz: QuizResultDetailResponse
        public let user: User?
        
        private enum CodingKeys: String, CodingKey {
            case shareURL = "share_url"
            case teams, answers, quiz, user
        }
    }
    
    public struct TeamElement: Codable {
        public let team: TeamTeam
        public let percentage: Double
    }
    
    public struct TeamTeam: Codable {
        public let id: Int
        public let title: String
        public let avatar: String
    }
    
    public struct QuizResultDetailResponse: Codable {
        public let id: String
        public let title: String?
        public let description: String?
        public let image: ImageQuiz?
        public let questionCount: Int?
        
        private enum Codingkeys: String, CodingKey {
            case id, title, description, image
            case questionCount = "quiz_questions_count"
        }
    }
    
    public struct ImageQuiz: Codable {
        public let url: String?
        public let thumbnail: Url?
        public let thumbnail_square: Url?
        public let large: Url?
        public let large_square: Url?
        
        public struct Url: Codable {
            public let url: String?
        }
    }
}

