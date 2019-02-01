//
//  NotificationAPI.swift
//  Networking
//
//  Created by Hanif Sugiyanto on 01/02/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import Moya
import Common


public enum NotificationAPI {
    case recordNotification
}

extension NotificationAPI: TargetType {
    
    public var headers: [String : String]? {
        let token = KeychainService.load(type: NetworkKeychainKind.token) ?? ""
        return [
            "Content-Type"  : "application/json",
            "Accept"        : "application/json",
            "Authorization" : token
        ]
    }
    
    public var baseURL: URL {
        return URL(string: AppContext.instance.infoForKey("URL_API_NOTIFICATION"))!
    }
    
    public var path: String {
        switch self {
        case .recordNotification:
            return "/v1/records/notification"
        }
    }
    
    public var method: Moya.Method {
        switch self {
        default:
            return .get
        }
    }
    
    public var parameters: [String: Any]? {
        switch self {
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
    
}
