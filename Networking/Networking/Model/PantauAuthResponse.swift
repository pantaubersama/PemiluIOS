//
//  PantauAuthResponse.swift
//  Networking
//
//  Created by Hanif Sugiyanto on 20/12/18.
//  Copyright © 2018 PantauBersama. All rights reserved.
//

import Foundation

public struct PantauAuthResponse: Codable {
    
    public var data: D?
        
    public struct D: Codable {
        public var accessToken: String
        public var tokenType: String
        public var refreshToken: String
        public var expiresIn: Int
        public var createdAt: Int
        
        private enum CodingKeys: String, CodingKey {
            case accessToken = "access_token"
            case tokenType = "token_type"
            case refreshToken = "refresh_token"
            case expiresIn = "expires_in"
            case createdAt = "created_at"
        }
        
    }
}

