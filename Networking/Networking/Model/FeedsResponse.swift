//
//  FeedsResponse.swift
//  Networking
//
//  Created by wisnu bhakti on 31/12/18.
//  Copyright © 2018 PantauBersama. All rights reserved.
//

import Foundation

public struct FeedsResponse: Codable {
    
    public var feeds: [Feeds]
    public let meta: Meta
    
    private enum CodingKeys: String, CodingKey {
        case feeds
        case meta
    }
    
}
