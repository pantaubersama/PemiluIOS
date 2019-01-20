//
//  InfoFirebaseResponse.swift
//  Networking
//
//  Created by Hanif Sugiyanto on 20/01/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import Foundation

public struct InfoFirebaseResponse: Codable {
    
    public let firebaseKey: Info
    
    
    public struct Info: Codable {
        public let type: String
        public let content: String
        public let userId: String
        
        private enum CodingKeys: String, CodingKey {
            case type = "key_type"
            case content
            case userId = "user_id"
        }
    }
    
    private enum CodingKeys: String, CodingKey {
        case firebaseKey = "firebase_key"
    }
    
}
