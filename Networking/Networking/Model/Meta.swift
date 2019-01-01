//
//  Meta.swift
//  Networking
//
//  Created by wisnu bhakti on 31/12/18.
//  Copyright © 2018 PantauBersama. All rights reserved.
//

import Foundation

public struct Meta: Codable {
    public let pages: Pagination
    
    public struct Pagination: Codable {
        public let total: Int
        public let perPage: Int?
        public let page: Int
        
        private enum CodingKeys: String, CodingKey {
            case total
            case perPage = "per_page"
            case page
        }
    }
}
