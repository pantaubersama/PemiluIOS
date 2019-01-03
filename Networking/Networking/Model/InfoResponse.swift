//
//  InfoResponse.swift
//  Networking
//
//  Created by wisnu bhakti on 03/01/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import Foundation

public struct InfoResponse: Codable {
    public var data: Info
    
    public struct Info: Codable {
        public var message: String
    }
}
