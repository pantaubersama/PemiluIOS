//
//  OpiniumServicesAPI.swift
//  Networking
//
//  Created by Hanif Sugiyanto on 22/02/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import Moya
import Common

public enum OpiniumServiceAPI {
    case tagKajian(page: Int, perPage: Int, q: String)
    case crawl(url: String, refetch: Bool)
}

extension OpiniumServiceAPI: TargetType {
    
    
    
    public var headers: [String : String]? {
        let APIKey = AppContext.instance.infoForKey("APIKey_OPINIUM")
        return [
            "Content-Type"  : "application/json",
            "Accept"        : "application/json",
            "ApiKey"        : APIKey
        ]
    }
    
    
    public var baseURL: URL {
         return URL(string: AppContext.instance.infoForKey("URL_API_OPINIUM_SERVICE") )!
    }
    
    public var path: String {
        switch self {
        case .tagKajian:
            return "/opinium_service/v1/tags"
        case .crawl:
            return "/common/v1/crawl"
        }
    }
    
    public var method: Moya.Method {
        switch self {
        default:
            return .get
        }
    }
    
    public var sampleData: Data {
        return Data()
    }
    
    public var task: Task {
        switch self {
        default:
            return .requestParameters(parameters: parameters ?? [:], encoding: parameterEncoding)
        }
    }
    
    public var parameters: [String: Any]? {
        switch self {
        case .tagKajian(let (page, perPage, q)):
            return [
                "page": page,
                "per_page": perPage,
                "q": q
            ]
        case .crawl(let (url, refetch)):
            return [
                "url": url,
                "refetch": refetch
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
}
