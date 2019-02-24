//
//  WordstadiumAPI.swift
//  Networking
//
//  Created by Hanif Sugiyanto on 22/02/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import Moya
import Common

public enum WordstadiumAPI {
    case createChallengeOpen(statement: String, source: String, timeAt: String, timeLimit: Int, topic: String)
    case getPersonalChallenges(type: ProgressType)
    case getPublicChallenges(type: ProgressType)
    
    
}

extension WordstadiumAPI: TargetType {
    
    public var headers: [String: String]? {
        let token = KeychainService.load(type: NetworkKeychainKind.token) ?? ""
        return [
            "Content-Type"  : "application/json",
            "Accept"        : "application/json",
            "Authorization" : token
        ]
    }
    
    public var baseURL: URL {
        return URL(string: AppContext.instance.infoForKey("URL_API_WORDSTADIUM"))!
    }
    
    public var path: String {
        switch self {
        case .createChallengeOpen:
            return "/word_stadium/v1/challenges/open"
        case .getPersonalChallenges:
            return "/word_stadium/v1/challenges/me"
        case .getPublicChallenges:
            return "/word_stadium/v1/challenges/all"
        }
    }
    
    public var method: Moya.Method {
        switch self {
        case .createChallengeOpen:
            return .post
        default:
            return .get
        }
    }
    
    public var parameters: [String: Any]? {
        switch self {
        case .getPublicChallenges(let type):
            print(type.text)
            return [
                "progress": type.text
            ]
        case .getPersonalChallenges(let type):
            return [
                "progress": type.text
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
        case .createChallengeOpen:
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
        case .createChallengeOpen(let (statement, source, timeAt, timeLimit, topic)):
            var multipartFormData = [MultipartFormData]()
            multipartFormData.append(buildMultipartFormData(key: "statement", value: statement))
            multipartFormData.append(buildMultipartFormData(key: "statement_source", value: source))
            multipartFormData.append(buildMultipartFormData(key: "show_time_at", value: timeAt))
            multipartFormData.append(buildMultipartFormData(key: "time_limit", value: "\(timeLimit)"))
            multipartFormData.append(buildMultipartFormData(key: "topic_list", value: topic))
            return multipartFormData
        default:
            return nil
        }
    }
}

extension WordstadiumAPI {
    private func buildMultipartFormData(key: String, value: String) -> MultipartFormData {
        return MultipartFormData(provider: .data(value.data(using: String.Encoding.utf8, allowLossyConversion: true)!), name: key)
    }
}
