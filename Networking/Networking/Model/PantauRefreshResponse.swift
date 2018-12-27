//
//  PantauRefreshResponse.swift
//  Networking
//
//  Created by Hanif Sugiyanto on 27/12/18.
//  Copyright © 2018 PantauBersama. All rights reserved.
//

import Foundation

public struct PantauRefreshResponse: Codable {
    
    public var accessToken: String
    public var tokenType: String
    public var expireIn: Int
    public var refreshToken: String
    public var createdAt: Int
    
    private enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case tokenType = "token_type"
        case refreshToken = "refresh_token"
        case expireIn = "expires_in"
        case createdAt = "created_at"
    }
    
}
