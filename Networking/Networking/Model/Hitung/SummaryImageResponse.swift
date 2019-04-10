//
//  SummaryImageResponse.swift
//  Networking
//
//  Created by Hanif Sugiyanto on 10/04/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import Foundation

public class SummaryImageResponse: Codable {
    
    public let image: [ImageResponse]
    public let meta: Meta
    
}


public struct ImageResponse: Codable {
    public let createdAt: String
    public let createdInWord: CreatedInWord
    public let id: String
    public let file: FileImage
    public let hitungRealCountId: String
    public let realCount: RealCount
    public let type: String
    
    public struct FileImage: Codable {
        public let url: String
        public let thumbnail: DataUrl
        
        public struct DataUrl: Codable {
            public let url: String?
        }
    }
    
    private enum CodingKeys: String, CodingKey {
        case id, file
        case createdAt = "created_at"
        case createdInWord = "created_at_in_word"
        case hitungRealCountId = "hitung_real_count_id"
        case realCount = "real_count"
        case type = "image_type"
    }
}
