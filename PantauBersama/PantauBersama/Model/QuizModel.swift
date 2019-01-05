//
//  QuizModel.swift
//  PantauBersama
//
//  Created by Rahardyan Bisma Setya Putra on 04/01/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import Foundation
import Networking

class QuizModel {
    let id: String
    let title: String
    let description: String
    let image: ImageModel
    let questionCount: Int
    let participationStatus: QuizStatus
    
    init(quiz: Quiz) {
        self.id = quiz.id
        self.title = quiz.title
        self.description = quiz.description
        self.image = ImageModel(url: quiz.image?.url ?? "",
                                thumbnail: ImageModel.ImageSize(url: quiz.image?.thumbnail?.url ?? ""),
                                thumbnailSquare: ImageModel.ImageSize(url: quiz.image?.thumbnailSquare?.url ?? ""),
                                medium: ImageModel.ImageSize(url: quiz.image?.large?.url ?? ""),
                                mediumSquare: ImageModel.ImageSize(url: quiz.image?.largeSquare?.url ?? ""))
        self.questionCount = quiz.quizQuestionsCount
        self.participationStatus = QuizStatus(rawValue: quiz.participationStatus) ?? .notParticipating
    }
    
    public enum QuizStatus: String {
        case notParticipating = "not_participating"
        case inProgress = "in_progress"
        case finished = "finish"
    }
}

extension QuizModel {
    var subtitle: String {
        return "\(questionCount) Pertanyaan"
    }
}
