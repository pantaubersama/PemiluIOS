//
//  TanyaKandidatAPI.swift
//  Networking
//
//  Created by Rahardyan Bisma on 27/12/18.
//  Copyright © 2018 PantauBersama. All rights reserved.
//

import Moya
import Common

enum TanyaKandidatAPI {
    public enum TanyaListFilter: String {
        case userVerifiedAll = "user_verified_all"
        case userVerifiedTrue = "user_verified_true"
        case userVerifiedFalse = "user_verified_false"
    }
    
    case deleteQuestion(id: String)
    case getQuestions(page: Int, perpage: Int, filteredBy: TanyaListFilter)
    case createQuestion(body: String)
    case getQuestionDetail(id: String)
    case reportQuestion(id: String, className: String)
    case voteQuestion(id: String, className: String)
}

extension TanyaKandidatAPI: TargetType {
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
        case .deleteQuestion:
            return "/v1/questions"
        case .getQuestions:
            return "/v1/questions"
        case .createQuestion:
            return "/v1/questions"
        case .getQuestionDetail:
            return "/v1/questions"
        case .reportQuestion:
            return "/v1/reports"
        case .voteQuestion:
            return "v1/votes"
        }
    }
    
    public var method: Moya.Method {
        switch self {
        case .deleteQuestion:
            return .delete
        case .getQuestions, .getQuestionDetail:
            return .get
        case .createQuestion, .reportQuestion, .voteQuestion:
            return .post
        }
    }
    
    public var parameters: [String: Any]? {
        switch self {
        case .deleteQuestion(let id):
            return [
                "id": id
            ]
        case .getQuestions(let (page, perpage, filteredBy)):
            return [
                "page": page,
                "per_page": perpage,
                "filter_by": filteredBy.rawValue
            ]
        case .createQuestion(let body):
            return [
                "body": body
            ]
        case .getQuestionDetail(let id):
            return [
                "id": id
            ]
        case .reportQuestion(let (id, className)):
            return [
                "id": id,
                "class_name": className
            ]
        case .voteQuestion(let (id, className)):
            return [
                "id": id,
                "class_name": className
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