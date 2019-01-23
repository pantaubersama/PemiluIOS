//
//  LinimasaAPI.swift
//  Networking
//
//  Created by wisnu bhakti on 27/12/18.
//  Copyright © 2018 PantauBersama. All rights reserved.
//

import Moya
import Common

public enum LinimasaAPI {
    case getBannerInfos(pageName: String)
    case getFeeds(filter: String, page: Int, perPage: Int, query: String)
    case getJanjiPolitiks(query: String, cid: String, filter: String, page: Int, perPage: Int)
    case deleteJanjiPolitiks(id: String)
    case createJanjiPolitiks(title: String, body: String, image: UIImage?)
    case editJanjiPolitiks(title: String, image: UIImage?)
    case getMyJanjiPolitiks(page: Int, perPage: Int, query: String)
    case appVersions(type: String)
    case getUserJanpol(id: String, page: Int, perPage: Int, query: String)
}

extension LinimasaAPI: TargetType {
    
    public var headers: [String: String]? {
        let token = KeychainService.load(type: NetworkKeychainKind.token) ?? ""
        return [
            "Content-Type"  : "application/json",
            "Accept"        : "application/json",
            "Authorization" : token
        ]
    }
    
    public var baseURL: URL {
        let url = URL(string: AppContext.instance.infoForKey("URL_API_PEMILU"))!
        return url
    }
    
    public var path: String {
        switch self {
        case .getBannerInfos:
            return "/linimasa/v1/banner_infos/show"
        case .getFeeds:
            return "/linimasa/v1/feeds/pilpres"
        case .getJanjiPolitiks,
             .deleteJanjiPolitiks,
             .createJanjiPolitiks,
             .editJanjiPolitiks:
            return "/linimasa/v1/janji_politiks"
        case .getMyJanjiPolitiks:
            return "/linimasa/v1/janji_politiks/me"
        case .appVersions:
            return "/dashboard/v1/app_versions/last_version"
        case .getUserJanpol(let (id,_,_,_)):
            return "/linimasa/v1/janji_politiks/user/\(id)"
        }
    }
    
    public var parameters: [String: Any]? {
        switch self {
        case .getBannerInfos(let pageName):
            return [
                "page_name": pageName
            ]
        case .getFeeds(let (filter, page, perPage, query)):
            return [
                "filter_by": filter,
                "page": page,
                "per_page": perPage,
                "q": query
            ]
        case .getJanjiPolitiks(let (query, cid, filter, page, perPage)):
            return [
                "q": query,
                "cluster_id": cid,
                "filter_by": filter,
                "page": page,
                "per_page": perPage
            ]
        case .deleteJanjiPolitiks(let id):
            return [
                "id": id
            ]
        case .getMyJanjiPolitiks(let (page, perPage, query)):
            return [
                "q": query,
                "page": page,
                "per_page": perPage
            ]
        case .appVersions(let type):
            return [
                "app_type": type
            ]
        case .getUserJanpol(let (_, page, perPage, query)):
            return [
                "q": query,
                "page": page,
                "per_page": perPage
            ]
        default:
            return nil
        }
    }
    
    public var method: Moya.Method {
        switch self {
        case .getBannerInfos,
             .getFeeds,
             .getJanjiPolitiks,
             .getMyJanjiPolitiks,
             .appVersions,
             .getUserJanpol:
            return .get
        case .deleteJanjiPolitiks:
            return .delete
        case .createJanjiPolitiks:
            return .post
        case .editJanjiPolitiks:
            return .put
        }
    }
    
    public var parameterEncoding: ParameterEncoding {
        
        switch self.method {
        case .post, .put:
            return JSONEncoding.default
        default:
            return URLEncoding.default
        }
    }
    
    public var task: Task {
        switch self {
        case .createJanjiPolitiks,
             .editJanjiPolitiks:
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
        
        case .createJanjiPolitiks(let (title, body, image)):
            var multipartFormData = [MultipartFormData]()
            multipartFormData.append(buildMultipartFormData(key: "title", value: title))
            multipartFormData.append(buildMultipartFormData(key: "body", value: body))
            if let image = image?.jpegData(compressionQuality: 0.1) {
                multipartFormData.append(buildMultipartFormData(name: "image", value: image))
            }
            return multipartFormData
        case .editJanjiPolitiks(let (title, image)):
            var multipartFormData = [MultipartFormData]()
            multipartFormData.append(buildMultipartFormData(key: "title", value: title))
            if let image = image?.jpegData(compressionQuality: 0.1) {
                multipartFormData.append(buildMultipartFormData(name: "image", value: image))
            }
            return multipartFormData
        default:
            return nil
        }
    }

}

extension LinimasaAPI {
    private func buildMultipartFormData(key: String, value: String) -> MultipartFormData {
        return MultipartFormData(provider: .data(value.data(using: String.Encoding.utf8, allowLossyConversion: true)!), name: key)
    }
    
    private func buildMultipartFormData(name: String? = nil, value: Data) -> MultipartFormData {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "ddMMyyyyHHmmss"
        return MultipartFormData(provider: .data(value), name: name ?? "image[]", fileName: "pantau-ios-\(dateFormatter.string(from: Date())).jpg", mimeType:"image/jpeg")
    }
}
