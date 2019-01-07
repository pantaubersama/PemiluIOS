//
//  QuizAnswerKeyModel.swift
//  PantauBersama
//
//  Created by Rahardyan Bisma Setya Putra on 07/01/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import Foundation
import Networking

struct QuizSummaryModel: Codable {
    let id, content: String
    let answers: [Answer]
    let answered: Answer
    
    init(questionSummary: QuizSummaryResponse.Question) {
        self.id = questionSummary.id
        self.content = questionSummary.content
        self.answers = questionSummary.answers.map({ (answerResponse) -> Answer in
            return Answer(id: answerResponse.id, content: answerResponse.content, team: Team(id: answerResponse.team.id, title: answerResponse.team.title, avatar: answerResponse.team.avatar))
        })
        self.answered = Answer(id: questionSummary.answered.id, content: questionSummary.answered.content, team: Team(id: questionSummary.answered.team.id, title: questionSummary.answered.team.title, avatar: questionSummary.answered.team.avatar))
    }
    
    struct Answer: Codable {
        let id, content: String
        let team: Team
    }
    
    struct Team: Codable {
        let id: Int
        let title: String
        let avatar: String
    }
}
