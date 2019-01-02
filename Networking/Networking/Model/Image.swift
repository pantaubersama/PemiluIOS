//
//  Image.swift
//  Networking
//
//  Created by wisnu bhakti on 01/01/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import Foundation

public struct Image: Codable {
    public var url: String?
    public var small: Url?
    public var medium: Url?
    public var large: Url?
    
    public struct Url: Codable {
        public var url: String?
    }
    
    private enum CodingKeys: String, CodingKey {
        case url
        case small
        case medium
        case large
    }
    
}
