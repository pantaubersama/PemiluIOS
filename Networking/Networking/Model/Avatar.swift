//
//  Avatar.swift
//  Networking
//
//  Created by Hanif Sugiyanto on 31/12/18.
//  Copyright © 2018 PantauBersama. All rights reserved.
//

import Foundation

// MARK
// Some avatar not using medium
// you need extra to define another responsee
public struct Avatar: Codable {
    public var url: String?
    public var thumbnail: Url
    public var thumbnailSquare: Url
    public var medium: Url
    public var mediumSquare: Url
    
    public struct Url: Codable {
        public var url: String?
    }
    
    private enum CodingKeys: String, CodingKey {
        case url
        case thumbnail
        case thumbnailSquare = "thumbnail_square"
        case medium
        case mediumSquare = "medium_square"
    }
    
}
