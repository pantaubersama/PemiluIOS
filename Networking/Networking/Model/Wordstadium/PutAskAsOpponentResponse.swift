//
//  PutAskAsOpponentResponse.swift
//  Networking
//
//  Created by Rahardyan Bisma Setya Putra on 28/02/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import Foundation

public struct PutAskAsOpponentResponse: Codable {
    public let data: DataClass
    
    public struct DataClass: Codable {
        public let message: String
    }
}
