//
//  QuizAPI.swift
//  Networking
//
//  Created by Rahardyan Bisma on 04/01/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import Moya
import Common

public enum QuizAPI {
    public enum QuizListFilter: String {
        case all = "all"
        case notParticipating = "not_participating"
        case inProgress = "in_progress"
        case finished = "finished"
    }
    
    case getQuizSummary(id: String)
    case getQuizResult(id: String)
    case getQuizQuestions(id: String)
    case answerQUestion(id: String, questionId: String, answerId: String)
    case getQuizDetail(id: String)
    case getQuizzes(page: Int, perPage: Int, filterBy: QuizListFilter)
    case getTotalResult()
}

extension QuizAPI: TargetType {
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
        case .getQuizSummary(let id):
            return "/pendidikan_politik/v1/quizzes/\(id)/summary"
        case .getQuizResult(let id):
            return "/pendidikan_politik/v1/quizzes/\(id)/result"
        case .getQuizQuestions(let id):
            return "/pendidikan_politik/v1/quizzes/\(id)/questions"
        case .answerQUestion(let (id, _, _)):
            return "/pendidikan_politik/v1/quizzes/\(id)/questions"
        case .getQuizDetail(let id):
            return "/pendidikan_politik/v1/quizzes/\(id)"
        case .getQuizzes:
            return "/pendidikan_politik/v1/quizzes"
        case .getTotalResult:
            return "/pendidikan_politik/v1/me/quizzes"
        }
    }
    
    public var method: Moya.Method {
        switch self {
        case .answerQUestion:
            return .post
        default:
            return .get
        }
    }
    
    public var parameters: [String: Any]? {
        switch self {
        case .getQuizSummary(let id):
            return [
                "id": id
            ]
        case .getQuizResult(let id):
            return [
                "id": id
            ]
        case .getQuizQuestions(let id):
            return [
                "id": id
            ]
        case .answerQUestion(let (id, questionId, answerId)):
            return [
                "id": id,
                "question_id": questionId,
                "answer_id": answerId
            ]
        case .getQuizDetail(let id):
            return [
                "id": id
            ]
        case .getQuizzes(let (page, perPage, filterBy)):
            return [
                "page": page,
                "per_page": perPage,
                "filter_by": filterBy
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
