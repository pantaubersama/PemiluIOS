//
//  IndentitasAPI.swift
//  Networking
//
//  Created by Hanif Sugiyanto on 20/12/18.
//  Copyright © 2018 PantauBersama. All rights reserved.
//

import Moya

public enum IdentitasAPI {
    case loginIdentitas(code: String, grantType: String, clientId: String, clientSecret: String, redirectURI: String)
}

extension IdentitasAPI: TargetType {
    
    public var headers: [String : String]? {
        return [
            "Content-Type"  : "application/json",
            "Accept"        : "application/json",
        ]
    }
    
    public var baseURL: URL {
        return URL(string: "https://identitas.extrainteger.com")!
    }
    
    public var path: String {
        switch self {
        case .loginIdentitas:
            return "/oauth/token"
        }
    }
    
    public var method: Moya.Method {
        switch self {
        case .loginIdentitas:
            return .post
        }
    }
    
    public var parameters: [String: Any]? {
        switch self {
        case .loginIdentitas(let (code, grantType, clientId, clientSecret, redirectURI)):
            return [
                "code" : code,
                "grant_type": grantType,
                "client_id": clientId,
                "client_secret": clientSecret,
                "redirect_uri": redirectURI
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
