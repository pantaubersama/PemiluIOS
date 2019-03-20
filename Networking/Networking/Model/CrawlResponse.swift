//
//  CrawlResponse.swift
//  Networking
//
//  Created by Hanif Sugiyanto on 20/03/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import Foundation

public class CrawlResponse: Codable {
    
    public let url: Crawl
    
    public struct Crawl: Codable {
        public let source: SourceCrawl
        public let sourceUrl: String?
        public let title: String?
        public let description: String?
        public let bestImage: String?
        
        private enum CodingKeys: String, CodingKey {
            case source, title, description
            case sourceUrl = "source_url"
            case bestImage = "best_image"
        }
    }
    
    public struct SourceCrawl: Codable {
        public let id: String
        public let name: String?
        public let image: CrawlImage?
        public let displayName: String?
        
        private enum CodingKeys: String, CodingKey {
            case id, name, image
            case displayName = "display_name"
        }
    }
    
    
    public struct CrawlImage: Codable {
        public let url: String?
        public let thumb: Url
        
        public struct Url: Codable {
            public let url: String?
        }
    }
    
}
