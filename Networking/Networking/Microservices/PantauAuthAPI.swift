//
//  PantauAuthAPI.swift
//  Networking
//
//  Created by Hanif Sugiyanto on 20/12/18.
//  Copyright © 2018 PantauBersama. All rights reserved.
//



// MARK:
// Function Pantau Authorizations
// TODO:- Get access token from Pantau

import Moya
import Common

public enum PantauAuthAPI {
    case callback(code: String, provider: String)
    
    public enum GrantType: String {
        case refreshToken = "refresh_token"
    }
    
    case refresh(type: GrantType)
    case revoke
    
}

extension PantauAuthAPI: TargetType {
    
    public var headers: [String: String]? {
        return [
            "Content-Type"  : "application/json",
            "Accept"        : "application/json",
        ]
    }
    
    public var baseURL: URL {
        return URL(string: AppContext.instance.infoForKey("URL_API_AUTH"))!
    }
    
    public var path: String {
        switch self {
        case .callback:
            return "/v1/callback"
        case .refresh:
            return "/oauth/token"
        case .revoke:
            return "/ouath/revoke"
        }
    }
    
    public var method: Moya.Method {
        switch self {
        case .callback:
            return .get
        case .refresh, .revoke:
            return .post
        }
    }

    public var parameters: [String: Any]? {
        switch self {
        case .callback(let (_, provider)):
            return [
                "provider_token": provider
            ]
        case .refresh(let type):
            let t = KeychainService.load(type: NetworkKeychainKind.refreshToken) ?? ""
            return [
                "grant_type": type.rawValue,
                "client_id": AppContext.instance.infoForKey("CLIENT_ID_AUTH"),
                "client_secret": AppContext.instance.infoForKey("CLIENT_SECRET_AUTH"),
                "refresh_token": t
            ]
        case .revoke:
            let t = KeychainService.load(type: NetworkKeychainKind.token) ?? ""
            return [
                "client_id": AppContext.instance.infoForKey("CLIENT_ID_AUTH"),
                "client_secret": AppContext.instance.infoForKey("CLIENT_SECRET_AUTH"),
                "token": t
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
