//
//  QuizAnswerResponse.swift
//  Networking
//
//  Created by Rahardyan Bisma on 06/01/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

// To parse the JSON, add this file to your project and do:
//
//   let quizAnswerResponse = try? newJSONDecoder().decode(QuizAnswerResponse.self, from: jsonData)

import Foundation

public struct QuizAnswerResponse: Codable {
    public let data: DataClass
    
    public struct DataClass: Codable {
        public let quizParticipation: QuizParticipation
        public let meta: Meta
        
        enum CodingKeys: String, CodingKey {
            case quizParticipation = "quiz_participation"
            case meta
        }
    }
    
    public struct Meta: Codable {
        public let quizzes: Quizzes
    }
    
    public struct Quizzes: Codable {
        public let quizQuestionsCount, answeredQuestionsCount: Int
        
        enum CodingKeys: String, CodingKey {
            case quizQuestionsCount = "quiz_questions_count"
            case answeredQuestionsCount = "answered_questions_count"
        }
    }
    
    public struct QuizParticipation: Codable {
        public let id, status: String
        public let participatedAt: ParticipatedAt
        
        enum CodingKeys: String, CodingKey {
            case id, status
            case participatedAt = "participated_at"
        }
    }
    
    public struct ParticipatedAt: Codable {
        public let iso8601, en, id: String
        
        enum CodingKeys: String, CodingKey {
            case iso8601 = "iso_8601"
            case en, id
        }
    }
    

}
