//
//  ImageModel.swift
//  PantauBersama
//
//  Created by Rahardyan Bisma Setya Putra on 04/01/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import Foundation

public struct ImageModel: Codable {
    let url: String
    let thumbnail, thumbnailSquare, medium, mediumSquare: ImageSize
    
    struct ImageSize: Codable {
        let url: String
    }
}
