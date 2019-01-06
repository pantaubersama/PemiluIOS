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
        public let teams: [TeamElement]
        public let answers: [Int]
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

}
