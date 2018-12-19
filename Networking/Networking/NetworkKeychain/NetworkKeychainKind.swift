//
//  NetworkKeychainKind.swift
//  Networking
//
//  Created by Hanif Sugiyanto on 20/12/18.
//  Copyright © 2018 PantauBersama. All rights reserved.
//

import Foundation
import Common

public enum NetworkKeychainKind: KeychainKind {
    case token
    case refreshToken
    
    public var service: String {
        get {
            switch self {
            case .token:
                return "kPANTAUokenService"
            case .refreshToken:
                return "kPANTAURefreshTokenService"
            }
        }
    }
    
    public var account: String {
        get {
            switch self {
            case .token:
                return "kPANTAUTokenAccount"
            case .refreshToken:
                return "kPANTAURefreshTokenAccount"
            }
        }
    }
}
