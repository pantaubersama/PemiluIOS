//
//  JanjiPolitikResponse.swift
//  Networking
//
//  Created by wisnu bhakti on 01/01/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import Foundation

public struct JanjiPolitikResponse: Codable {
    
    public var janjiPolitiks: [JanjiPolitik]
    public let meta: Meta
    
    private enum CodingKeys: String, CodingKey {
        case janjiPolitiks = "janji_politiks"
        case meta
    }
    
}
