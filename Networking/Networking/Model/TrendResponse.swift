//
//  TrendResponse.swift
//  Networking
//
//  Created by wisnu bhakti on 08/01/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import Foundation

public struct TrendResponse: Codable {
    public let teams: [TeamElement]
    public let meta: MetaTrend
    
    public struct TeamElement: Codable {
        public let team: TeamTeam
        public let percentage: Double?
    }
    
    public struct TeamTeam: Codable {
        public let id: Int
        public let title: String
        public let avatar: String
    }
    
    public struct MetaTrend: Codable {
        public let quizzes: QuizTrend
    }
    
    public struct QuizTrend: Codable {
        public let total: Int
        public let finished: Int
    }
    
}
