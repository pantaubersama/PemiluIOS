//
//  FirebaseQuizNotifResponse.swift
//  Networking
//
//  Created by Rahardyan Bisma on 17/02/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import Foundation

public struct FirebaseQuizNotifResponse: Codable {
    public var notification: Notif
    public var broadcast: NotifQuiz
}

public struct NotifQuiz: Codable {
    public var id: String
    public var description: String
    public var title: String
    public var quizQuestionsCount: Int
    
    private enum CodingKeys: String, CodingKey {
        case id, description, title
        case quizQuestionsCount = "quiz_questions_count"
    }
}
