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
    case me
    case verifications
    case putKTP(ktp: String)
    
}

extension PantauAuthAPI: TargetType {
    
    public var headers: [String: String]? {
        let token = KeychainService.load(type: NetworkKeychainKind.token) ?? ""
        print("TOKEN:\(token)")
        return [
            "Content-Type"  : "application/json",
            "Accept"        : "application/json",
            "Authorization" : token
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
        case .me:
            return "/v1/me"
        case .verifications:
            return "/v1/me/verifications"
        case .putKTP:
            return "/v1/verifications/ktp_number"
        }
    }
    
    public var method: Moya.Method {
        switch self {
        case .refresh, .revoke:
            return .post
        case .putKTP:
            return .put
        default:
            return .get
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
        case .putKTP(let ktp):
            return [
                "ktp_number": ktp
            ]
        default:
            return nil
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
    
    public var multipartBody: [MultipartFormData]? {
        switch self {
        case .putKTP(let ktp):
            var multipartFormData = [MultipartFormData]()
            multipartFormData.append(buildMultipartFormData(key: "ktp_number", value: ktp))
            return multipartFormData
        default:
            return nil
        }
    }
}


extension PantauAuthAPI {
    
    private func buildMultipartFormData(key: String, value: String) -> MultipartFormData {
        return MultipartFormData(provider: .data(value.data(using: String.Encoding.utf8, allowLossyConversion: true)!), name: key)
    }
    
    private func buildMultipartFormData(name: String? = nil, value: Data) -> MultipartFormData {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "ddMMyyyyHHmmss"
        return MultipartFormData(provider: .data(value), name: name ?? "image[]", fileName: "pantau-ios-\(dateFormatter.string(from: Date())).jpg", mimeType:"image/jpeg")
    }
}
