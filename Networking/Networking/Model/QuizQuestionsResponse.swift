//
//  QuizQuestionsResponse.swift
//  Networking
//
//  Created by Rahardyan Bisma on 06/01/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

// To parse the JSON, add this file to your project and do:
//
//   let quizQuestionsResponse = try? newJSONDecoder().decode(QuizQuestionsResponse.self, from: jsonData)

import Foundation

public struct QuizQuestionsResponse: Codable {
    public let data: DataClass
    
    public struct DataClass: Codable {
        public let quizParticipation: QuizParticipation
        public let answeredQuestions: [Question]
        public let questions: [Question]
        public let meta: Meta
        
        enum CodingKeys: String, CodingKey {
            case quizParticipation = "quiz_participation"
            case answeredQuestions = "answered_questions"
            case questions, meta
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
    
    public struct Question: Codable {
        public let id, content: String
        public let answers: [Answer]
    }
    
    public struct Answer: Codable {
        public let id, content: String
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
