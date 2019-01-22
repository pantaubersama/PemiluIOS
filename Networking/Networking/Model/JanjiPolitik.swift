//
//  JanjiPolitik.swift
//  Networking
//
//  Created by wisnu bhakti on 01/01/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import Foundation

public struct JanjiPolitik: Codable {
    
    public let id: String
    public var title: String
    public var body: String
    public var image: Image?
    public var createdAt: String
    public var createdAtWord: CreatedAt
    public var creator: CreatorJanpol
    
    enum CodingKeys: String, CodingKey {
        case id, title, body, image, creator
        case createdAt = "created_at"
        case createdAtWord = "created_at_in_word"
    }
    
}

public struct CreatorJanpol: Codable {
    
    public let id: String
    public var email: String
    public var fullName: String
    public var about: String?
    public var avatar: Avatar
    public var cluster: ClusterDetail?
    
    private enum CodingKeys: String, CodingKey {
        case id
        case email
        case fullName = "full_name"
        case about
        case avatar
        case cluster
    }
}
