//
//  VerificationsResponse.swift
//  Networking
//
//  Created by Hanif Sugiyanto on 29/12/18.
//  Copyright © 2018 PantauBersama. All rights reserved.
//

import Foundation

public struct VerificationsResponse: Codable {
    
    public var user: U
    
    public struct U: Codable {
        public var id: String
        public var approved: Bool
        public var step: Int?
        public var nextStep: Int?
        public var verified: Bool
        
        private enum CodingKeys: String, CodingKey {
            case id = "user_id"
            case approved
            case step
            case nextStep = "next_step"
            case verified = "is_verified"
        }
    }
}
