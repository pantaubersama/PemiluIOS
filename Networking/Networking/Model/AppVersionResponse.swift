//
//  AppVersionResponse.swift
//  Networking
//
//  Created by Hanif Sugiyanto on 18/01/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import Foundation

public struct AppVersionResponse: Codable {
    
    public let app: App
    
    public struct App: Codable {
        public let id: String
        public let version: String?
        public let versionCode: String?
        public let appType: String?
        public let forceUpdate: Bool
        
        private enum CodingKeys: String, CodingKey {
            case id
            case version
            case versionCode = "version_code"
            case appType = "app_type"
            case forceUpdate = "force_update"
        }
    }
    
    private enum CodingKeys: String, CodingKey {
        case app = "app_version"
    }
}
