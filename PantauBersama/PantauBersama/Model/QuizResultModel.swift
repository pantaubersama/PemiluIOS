//
//  QuizResultModel.swift
//  PantauBersama
//
//  Created by Rahardyan Bisma on 06/01/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import Foundation
import Networking

public struct QuizResultModel {
    public let paslonNo: Int
    public let name: String
    public let percentage: String
    public let avatar: String
    public let nameQuiz: String
    public let userName: String
    
    init(result: QuizResultResponse.DataClass) {
        let higherPercentagePaslon = result.teams.sorted { (t1, t2) -> Bool in
            return t1.percentage > t2.percentage
        }.first
        
        self.paslonNo = higherPercentagePaslon?.team.id ?? 0
        self.name = higherPercentagePaslon?.team.title ?? ""
        self.avatar = higherPercentagePaslon?.team.avatar ?? ""
        self.percentage =  String(format: "%.0f", higherPercentagePaslon?.percentage ?? 0) + "%"
        self.nameQuiz = result.quiz.title ?? ""
        self.userName = result.user?.fullName ?? ""
    }
}

extension QuizResultModel {
    var resultSummary: String {
        return "Dari hasil pilihan di Quiz \(self.nameQuiz), \n\(self.userName) lebih suka jawaban dari Paslon no \(paslonNo)"
    }
}
