//
//  QuizSummaryResponse.swift
//  Networking
//
//  Created by Rahardyan Bisma Setya Putra on 07/01/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

// To parse the JSON, add this file to your project and do:
//
//   let quizSummaryResponse = try? newJSONDecoder().decode(QuizSummaryResponse.self, from: jsonData)

import Foundation

public struct QuizSummaryResponse: Codable {
    public let data: DataClass
    
    public struct DataClass: Codable {
        public let questions: [Question]
    }
    
    public struct Question: Codable {
        public let id, content: String
        public let answers: [Answer]
        public let answered: Answer
    }
    
    public struct Answer: Codable {
        public let id, content: String
        public let team: Team
    }
    
    public struct Team: Codable {
        public let id: Int
        public let title: String
        public let avatar: String
    }
}

