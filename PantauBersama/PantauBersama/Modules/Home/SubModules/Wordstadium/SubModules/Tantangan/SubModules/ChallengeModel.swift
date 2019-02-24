//
//  ChallengeModel.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 22/02/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

struct ChallengeModel {
    var tag: String?
    var statement: String?
    var source: String?
    var timeAt: String?
    var limitAt: String?
    var userId: String? = nil
    var screenName: String? = nil
    
    init(tag: String?, statement: String?, source: String?, timeAt: String, limitAt: String?, userId: String?, screenName: String?) {
        self.tag = tag
        self.statement = statement
        self.source = source
        self.timeAt = timeAt
        self.limitAt = limitAt
        self.userId = userId
        self.screenName = screenName
    }
}
