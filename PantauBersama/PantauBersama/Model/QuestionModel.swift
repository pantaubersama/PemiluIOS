//
//  QuestionModel.swift
//  PantauBersama
//
//  Created by Rahardyan Bisma on 27/12/18.
//  Copyright © 2018 PantauBersama. All rights reserved.
//

import Foundation
import Common
import Networking

public struct QuestionModel {
    let id, body: String
    let createdAt: CreatedAt
    let created: String
    var likeCount: Int
    var isLiked: Bool
    let user: Creator
    
    init(question: Question) {
        self.id = question.id
        self.body = question.body
        self.createdAt = CreatedAt(iso8601: question.createdAtInWord.iso8601,
                                 en: question.createdAtInWord.en,
                                 id: question.createdAtInWord.id)
        self.created = question.created
        self.likeCount = question.likeCount
        self.user = Creator(id: question.user.id,
                         email: question.user.email,
                         fullName: question.user.fullName,
                         username: question.user.username ?? "",
                         avatar: ImageModel(url: question.user.avatar.url ?? "",
                                             thumbnail: ImageModel.ImageSize(url: question.user.avatar.thumbnail.url ?? ""),
                                             thumbnailSquare: ImageModel.ImageSize(url: question.user.avatar.thumbnailSquare.url ?? ""),
                                             medium: ImageModel.ImageSize(url: question.user.avatar.medium.url ?? ""),
                                             mediumSquare: ImageModel.ImageSize(url: question.user.avatar.mediumSquare.url ?? "")),
                         verified: question.user.verified,
                         about: question.user.about ?? "")
        self.isLiked = question.isLiked
        
    }
    
    public struct CreatedAt {
        let iso8601, en, id: String
    }
    
    public struct Creator: Codable {
        let id, email, fullName: String
        let username: String
        let avatar: ImageModel
        let verified: Bool
        let about: String
    }
}

extension QuestionModel {
    var formatedLikeCount: String {
        var formatedCount = "0"
        
        if likeCount < 1000 {
            formatedCount = "\(likeCount)"
            return formatedCount
        }
            
        let kFormat = likeCount / 1000
        formatedCount = "\(kFormat)K"
        
        return formatedCount
    }
    
    var isMyQuestion: Bool {
        let userData: Data? = UserDefaults.Account.get(forKey: .me)
        let userResponse = try? JSONDecoder().decode(UserResponse.self, from: userData ?? Data())
        
        let userId = userResponse?.user.id ?? ""
        
        return self.user.id == userId
    }
}
