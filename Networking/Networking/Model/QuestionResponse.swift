//
//  QuestionResponse.swift
//  Networking
//
//  Created by Rahardyan Bisma on 27/12/18.
//  Copyright © 2018 PantauBersama. All rights reserved.
//

import Foundation

// To parse the JSON, add this file to your project and do:
//
//   let questionsResponse = try? newJSONDecoder().decode(QuestionsResponse.self, from: jsonData)

import Foundation

public struct QuestionsResponse: Codable {
    let data: DataClass
    
    public struct DataClass: Codable {
        let questions: [Question]
        let meta: Meta
        
        public struct Meta: Codable {
            let pages: Pages
            
            public struct Pages: Codable {
                let total, perPage, page: Int
                
                enum CodingKeys: String, CodingKey {
                    case total
                    case perPage = "per_page"
                    case page
                }
            }
        }
        
        public struct Question: Codable {
            let id, body: String
            let createdAt: CreatedAt
            let created: String
            let likeCount: Int
            let user: User
            
            enum CodingKeys: String, CodingKey {
                case id, body
                case createdAt = "created_at"
                case created
                case likeCount = "like_count"
                case user
            }
        }
        
        public struct CreatedAt: Codable {
            let iso8601, en, id: String
            
            enum CodingKeys: String, CodingKey {
                case iso8601 = "iso_8601"
                case en, id
            }
        }
        
        public struct User: Codable {
            let id, email, firstName, lastName: String
            let username: String
            let avatar: Avatar
            let verified: Bool
            let about: String
            
            enum CodingKeys: String, CodingKey {
                case id, email
                case firstName = "first_name"
                case lastName = "last_name"
                case username, avatar, verified, about
            }
            
            public struct Avatar: Codable {
                let url: String
                let thumbnail, thumbnailSquare, medium, mediumSquare: ImageSize
                
                enum CodingKeys: String, CodingKey {
                    case url, thumbnail
                    case thumbnailSquare = "thumbnail_square"
                    case medium
                    case mediumSquare = "medium_square"
                }
                
                struct ImageSize: Codable {
                    let url: String
                }
            }
        }
    }

}

