//
//  IdentitasResponses.swift
//  Networking
//
//  Created by Hanif Sugiyanto on 20/12/18.
//  Copyright © 2018 PantauBersama. All rights reserved.
//

import Foundation

public struct IdentitasResponses: Codable {

    public var accessToken: String
    public var tokenType: String
    public var refreshToken: String
    
    private enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case tokenType = "token_type"
        case refreshToken = "refresh_token"
    }
        
    
    
}
