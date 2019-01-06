//
//  QuizQuestionModel.swift
//  PantauBersama
//
//  Created by Rahardyan Bisma on 06/01/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import Foundation
import Networking

public struct QuizQuestionModel {
    public let id, content: String
    public let answers: [Answer]
    
    init(quizQuestion: QuizQuestionsResponse.Question) {
        self.id = quizQuestion.id
        self.content = quizQuestion.content
        self.answers = quizQuestion.answers.map({ (answerResponse) -> Answer in
            return Answer(id: answerResponse.id, content: answerResponse.content)
        })
    }
}

public struct Answer {
    public let id, content: String
}
