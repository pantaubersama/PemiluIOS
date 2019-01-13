//
//  AccountResponse.swift
//  Networking
//
//  Created by Hanif Sugiyanto on 12/01/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import Foundation

public struct AccountResponse: Codable {
    
    public let account: AccountSosmed
    
}


public struct AccountSosmed: Codable {
    public let id: String
    public let type: String?
    public let user: UserSosmed?
    
    private enum CodingKeys: String, CodingKey {
        case id
        case type = "account_type"
        case user
    }
}

// MARK
// User sosmed different with User codable
// Avoid Moya error object mapping
public struct UserSosmed: Codable {
    public let id: String
    public let email: String?
    public let fullname: String?
    public let username: String?
    public let avatar: Avatar?
    public let verified: Bool
    public let about: String?
    public let twitter: Bool
    public let facebook: Bool
    
    private enum CodingKeys: String, CodingKey {
        case id, email, username, avatar,
        verified, about, twitter, facebook
        case fullname = "full_name"
    }
}
