//
//  DeleteChallengeResponse.swift
//  Networking
//
//  Created by Hanif Sugiyanto on 21/03/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import Foundation

public struct DeleteChallengeResponse: Codable {
    public let data: Delete
    
    public struct Delete: Codable {
        public let message: String
    }
}
