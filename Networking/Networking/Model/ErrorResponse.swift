//
//  ErrorResponse.swift
//  Networking
//
//  Created by Hanif Sugiyanto on 20/12/18.
//  Copyright © 2018 PantauBersama. All rights reserved.
//

import Foundation

public struct ErrorResponse: Codable {
    public var error: Error
    
    public struct Error: Codable {
        public var errors: [String]
    }
}
