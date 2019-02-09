//
//  FirebaseQuestionNotifResponse.swift
//  Networking
//
//  Created by Rahardyan Bisma on 09/02/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import Foundation

public struct FirebaseQuestionNotifResponse: Codable {
    public var notification: Notif
    public var question: Question
    
    private enum CodingKeys: String, CodingKey {
        case notification, question
    }
}
