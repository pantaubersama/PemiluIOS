//
//  PostImageResponse.swift
//  Networking
//
//  Created by Hanif Sugiyanto on 11/04/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import Foundation

public struct PostImageResponse: Codable {
    
    public let image: ImageResponse
    public let status: Bool
    
}
