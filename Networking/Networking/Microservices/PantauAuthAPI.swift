//
//  PantauAuthAPI.swift
//  Networking
//
//  Created by Hanif Sugiyanto on 20/12/18.
//  Copyright © 2018 PantauBersama. All rights reserved.
//

import Moya


public enum PantauAuthAPI {
    case callback(code: String, provider: String)
}

extension PantauAuthAPI: TargetType {
    
    public var headers: [String: String]? {
        return [
            "Content-Type"  : "application/json",
            "Accept"        : "application/json",
        ]
    }
    
    public var baseURL: URL {
        return URL(string: "https://staging-auth.pantaubersama.com")!
    }
    
    public var path: String {
        switch self {
        case .callback:
            return "/v1/callback"
        }
    }
    
    public var method: Moya.Method {
        switch self {
        case .callback:
            return .get
        }
    }

    public var parameters: [String: Any]? {
        switch self {
        case .callback(let (_, provider)):
            return [
                "provider_token": provider
            ]
        }
    }
    
    public var parameterEncoding: ParameterEncoding {
        switch self.method {
        case .put, .post:
            return JSONEncoding.default
        default:
            return URLEncoding.default
        }
    }
    
    public var task: Task {
        switch self {
        default:
            return .requestParameters(parameters: parameters ?? [:], encoding: parameterEncoding)
        }
    }
    
    public var validate: Bool {
        switch self {
        default:
            return false
        }
    }
    
    public var sampleData: Data {
        return Data()
    }
}
