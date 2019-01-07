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
    
    init(result: QuizResultResponse.DataClass) {
        let higherPercentagePaslon = result.teams.sorted { (t1, t2) -> Bool in
            return t1.percentage > t2.percentage
        }.first
        
        self.paslonNo = higherPercentagePaslon?.team.id ?? 0
        self.name = higherPercentagePaslon?.team.title ?? ""
        self.avatar = higherPercentagePaslon?.team.avatar ?? ""
        self.percentage = "\(higherPercentagePaslon?.percentage ?? 0)%"
    }
}

extension QuizResultModel {
    var resultSummary: String {
        // MARK
        // Get user data from userDefaults
        let userData: Data? = UserDefaults.Account.get(forKey: .me)
        let userResponse = try? JSONDecoder().decode(UserResponse.self, from: userData ?? Data())
        
        return "Dari hasil pilhan Quiz minggu pertama, \n\(userResponse?.user.fullName ?? "") lebih suka jawaban dari Paslon no \(paslonNo)"
    }
}
