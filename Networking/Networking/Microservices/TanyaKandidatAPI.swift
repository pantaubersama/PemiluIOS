//
//  TanyaKandidatAPI.swift
//  Networking
//
//  Created by Rahardyan Bisma on 27/12/18.
//  Copyright © 2018 PantauBersama. All rights reserved.
//

import Moya
import Common

public enum TanyaKandidatAPI {
    public enum TanyaListFilter: String {
        case userVerifiedAll = "user_verified_all"
        case userVerifiedTrue = "user_verified_true"
        case userVerifiedFalse = "user_verified_false"
    }
    
    public enum QuestionOrder: String {
        case created = "created_at"
        case cachedVoteUp = "cached_votes_up"
    }
    
    case deleteQuestion(id: String)
    case getQuestions(query: String, page: Int, perpage: Int, filteredBy: String, orderedBy: String)
    case getMyQuestions(page: Int, perpage: Int)
    case createQuestion(body: String)
    case getQuestionDetail(id: String)
    case reportQuestion(id: String, className: String)
    case voteQuestion(id: String, className: String)
    case deleteVoteQuestion(id: String, className: String)
    case getQuestionsId(id: String)
    case getUserQuestion(id: String, page: Int, perPage: Int)
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
        let url = URL(string: AppContext.instance.infoForKey("URL_API_PEMILU"))!
        return url
    }
    
    public var path: String {
        switch self {
        case .deleteQuestion:
            return "/pendidikan_politik/v1/questions"
        case .getQuestions:
            return "/pendidikan_politik/v1/questions"
        case .createQuestion:
            return "/pendidikan_politik/v1/questions"
        case .getQuestionDetail:
            return "/pendidikan_politik/v1/questions"
        case .reportQuestion:
            return "/pendidikan_politik/v1/reports"
        case .voteQuestion, .deleteVoteQuestion:
            return "/pendidikan_politik/v1/votes"
        case .getMyQuestions:
            return "/pendidikan_politik/v1/me/questions"
        case .getQuestionsId(let id):
            return "/pendidikan_politik/v1/questions/\(id)"
        case .getUserQuestion(let (id,_,_)):
            return "/pendidikan_politik/v1/users/\(id)/questions"
        }
    }
    
    public var method: Moya.Method {
        switch self {
        case .deleteQuestion, .deleteVoteQuestion:
            return .delete
        case .getQuestions,
             .getQuestionDetail,
             .getMyQuestions,
             .getQuestionsId,
             .getUserQuestion:
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
        case .getQuestions(let (query, page, perpage, filteredBy, orderBy)):
            return [
                "page": page,
                "per_page": perpage,
                "filter_by": filteredBy,
                "order_by": orderBy,
                "q": query
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
        case .voteQuestion(let (id, className)), .deleteVoteQuestion(let (id, className)):
            return [
                "id": id,
                "class_name": className
            ]
        case .getMyQuestions(let (page, perpage)):
            return [
                "page": page,
                "per_page": perpage
            ]
        case .getUserQuestion(let (_, page, perPage)):
            return [
                "page": page,
                "per_page": perPage
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
}
