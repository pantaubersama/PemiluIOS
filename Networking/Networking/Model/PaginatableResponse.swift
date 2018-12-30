//
//  PaginatableResponse.swift
//  Networking
//
//  Created by Hanif Sugiyanto on 30/12/18.
//  Copyright © 2018 PantauBersama. All rights reserved.
//

import Foundation

public struct PaginatableResponse<T>: Codable where T:Codable {
    
    // MARK
    // Pagination jika data meta diluar object data
    public let data: T
    public let meta: Meta
    
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
    
}
