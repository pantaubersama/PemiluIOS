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
    case putSelfieKTP(image: UIImage?)
    case putFotoKTP(image: UIImage?)
    case putSignature(image: UIImage?)
    case badges(page: Int, perPage: Int)
    case meInformant
    case meAvatar(avatar: UIImage?)
    case putMe(parameters: [String: Any])
    case putInformants(parameters: [String: Any])
    case achievedBadges(id: String)
    case clusters(q: String, page: Int, perPage: Int)
    case categories(q: String, page: Int, perPage: Int)
    case createCategories(t: String)
    
}

extension PantauAuthAPI: TargetType {
    
    public var headers: [String: String]? {
        let token = KeychainService.load(type: NetworkKeychainKind.token) ?? ""
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
        case .me, .putMe:
            return "/v1/me"
        case .verifications:
            return "/v1/me/verifications"
        case .putKTP:
            return "/v1/verifications/ktp_number"
        case .putSelfieKTP:
            return "/v1/verifications/ktp_selfie"
        case .putFotoKTP:
            return "/v1/verifications/ktp_photo"
        case .putSignature:
            return "/v1/verifications/signature"
        case .badges:
            return "/v1/badges"
        case .meInformant:
            return "/v1/me/informants"
        case .meAvatar:
            return "/v1/me/avatar"
        case .putInformants:
            return "/v1/informants"
        case .achievedBadges(let id):
            return "/v1/achieved_badges/\(id)"
        case .clusters:
            return "/v1/clusters"
        case .categories,
             .createCategories:
            return "/v1/categories"
        }
    }
    
    public var method: Moya.Method {
        switch self {
        case .refresh,
             .revoke,
             .createCategories:
            return .post
        case .putKTP,
             .putSelfieKTP,
             .putFotoKTP,
             .putSignature,
             .meAvatar,
             .putMe,
             .putInformants:
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
        case .badges(let (page, perPage)):
            return [
                "page": page,
                "per_page": perPage
            ]
        case .putMe(let parameters):
            return parameters
        case .putInformants(let parameters):
            return parameters
        case .clusters(let (q, page, perPage)):
            return [
                "q": q,
                "page": page,
                "per_page": perPage
            ]
        case .categories(let (q, page, perPage)):
            return [
                "name": q,
                "page": page,
                "per_page": perPage
            ]
        case .createCategories(let t):
            return [
                "name": t
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
        case .putKTP,
             .putSelfieKTP,
             .putFotoKTP,
             .putSignature,
             .meAvatar:
            return .uploadMultipart(self.multipartBody ?? [])
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
        case .putSelfieKTP(let image):
            var multipartFormData = [MultipartFormData]()
            if let selfie = image, let d = selfie.jpegData(compressionQuality: 0.1) {
                multipartFormData.append(buildMultipartFormData(name: "ktp_selfie", value: d))
                }
            return multipartFormData
        case .putFotoKTP(let image):
            var multipartFormData = [MultipartFormData]()
            if let selfie = image, let d = selfie.jpegData(compressionQuality: 0.1) {
                multipartFormData.append(buildMultipartFormData(name: "ktp_photo", value: d))
            }
            return multipartFormData
        case .putSignature(let image):
            var multipartFormData = [MultipartFormData]()
            if let selfie = image, let d = selfie.jpegData(compressionQuality: 0.1) {
                multipartFormData.append(buildMultipartFormData(name: "signature", value: d))
            }
            return multipartFormData
        case .meAvatar(let image):
            var multipartFormData = [MultipartFormData]()
            if let avatar = image, let d = avatar.jpegData(compressionQuality: 0.1) {
                multipartFormData.append(buildMultipartFormData(name: "avatar", value: d))
            }
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
