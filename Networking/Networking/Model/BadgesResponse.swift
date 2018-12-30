//
//  BadgesResponse.swift
//  Networking
//
//  Created by Hanif Sugiyanto on 30/12/18.
//  Copyright © 2018 PantauBersama. All rights reserved.
//

import Foundation

public struct BadgesResponse: Codable {
    
    public var achieved: [Badges]
    public var badges: [Badges]
    
    private enum CodingKeys: String, CodingKey {
        case achieved = "achieved_badges"
        case badges
    }
    
}


public struct Badges: Codable {
    
    public let id: String
    public var name: String?
    public var description: String?
    public var image: Avatar
    public var position: Int
    
    
    public struct Avatar: Codable {
        public let url: String?
        public let thumbnail, thumbnailSquare: ImageSize
        
        enum CodingKeys: String, CodingKey {
            case url, thumbnail
            case thumbnailSquare = "thumbnail_square"
        }
        
        public struct ImageSize: Codable {
            public let url: String?
        }
    }
}
