//
//  TagKajianResponse.swift
//  Networking
//
//  Created by Hanif Sugiyanto on 22/02/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import Foundation

public struct TagKajianResponse: Codable {
    
    public var tags: [TagKajian]
    public var meta: Meta
    
}

public struct TagKajian: Codable {
    public var id: String
    public var name: String
    public var count: Int
    
    private enum CodingKeys: String, CodingKey {
        case id, name
        case count = "posts_count"
    }
}
