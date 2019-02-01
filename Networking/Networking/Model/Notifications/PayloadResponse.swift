//
//  PayloadResponse.swift
//  Networking
//
//  Created by Hanif Sugiyanto on 01/02/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import Foundation

public struct PayloadResponse: Codable {
    
    public let notifType: String
    
    private enum CodingKeys: String, CodingKey {
        case notifType = "notif_type"
    }
}
