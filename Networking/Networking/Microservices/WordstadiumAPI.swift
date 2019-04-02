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
    case getChallengeDetail(id: String)
    case getChallenges(progress: ProgressType, type: LiniType, page: Int, perPage: Int)
    case createChallengeDirect(statement: String, source: String, timeAt: String, timeLimit: Int, topic: String, screenName: String, id: String)
    case askAsOpponent(id: String)
    case confirmCandidateAsOpponent(challengeId: String, audienceId: String)
    case confirmDirect(challengeId: String)
    case rejectDirect(challengeId: String, reason: String)
    case wordsAudience(challengeId: String, page: Int, perPage: Int)
    case commentAudience(challengeId: String, words: String)
    case fighterAttack(challengeId: String, words: String)
    case wordsFighter(challengeId: String, page: Int, perPage: Int)
    case deleteOpenChallenge(challengeId: String)
    case clapWord(wordId: String)
    case loveChallenge(challengeId: String)
    case unloveChallenge(challengeId: String)
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
        case .getChallenges(let (_,type,_,_)):
            return "/word_stadium/v1/challenges/\(type.url)"
        case .createChallengeDirect:
            return "/word_stadium/v1/challenges/direct"
        case .askAsOpponent:
            return "/word_stadium/v1/challenges/open/ask_as_opponent"
        case .getChallengeDetail(let id):
            return "/word_stadium/v1/challenges/\(id)"
        case .confirmCandidateAsOpponent:
            return "/word_stadium/v1/challenges/open/opponent_candidates"
        case .confirmDirect:
            return "/word_stadium/v1/challenges/direct/approve"
        case .rejectDirect:
            return "/word_stadium/v1/challenges/direct/reject"
        case .wordsAudience:
            return "/word_stadium/v1/words/audience"
        case .commentAudience:
            return "/word_stadium/v1/words/audience/comment"
        case .fighterAttack:
            return "/word_stadium/v1/words/fighter/attack"
        case .wordsFighter:
            return "/word_stadium/v1/words/fighter"
        case .deleteOpenChallenge(let id):
            return "/word_stadium/v1/challenges/open/delete/\(id)"
        case .clapWord:
            return "/word_stadium/v1/words/clap"
        case .loveChallenge, .unloveChallenge:
            return "/word_stadium/v1/challenges/like"
        }
    }
    
    public var method: Moya.Method {
        switch self {
        case .createChallengeOpen,
             .createChallengeDirect,
             .commentAudience,
             .fighterAttack:
            return .post
        case .askAsOpponent,
             .confirmCandidateAsOpponent,
             .confirmDirect,
             .rejectDirect,
             .clapWord,
             .loveChallenge:
            return .put
        case .deleteOpenChallenge,
             .unloveChallenge:
            return .delete
        default:
            return .get
        }
    }
    
    public var parameters: [String: Any]? {
        switch self {
        case .getChallenges(let (progress,_, page, perPage)):
            return [
                "progress": progress.text,
                "page": page,
                "per_page": perPage
            ]
        case .askAsOpponent(let id):
            return [
                "id": id
            ]
        case .confirmCandidateAsOpponent(let (challengeId, audienceId)):
            return [
                "id": challengeId,
                "audience_id": audienceId
            ]
        case .fighterAttack(let (challengeId, words)):
            return [
                "challenge_id": challengeId,
                "words": words
            ]
        case .commentAudience(let (challengeId, words)):
            return  [
                "challenge_id": challengeId,
                "words": words
            ]
        case .wordsAudience(let (challengeId, page, perPage)):
            return [
                "challenge_id": challengeId,
                "page": page,
                "per_page": perPage
            ]
        case .wordsFighter(let (challengeId, page, perPage)):
            return [
                "challenge_id": challengeId,
                "page": page,
                "per_page": perPage
            ]
        case .clapWord(let wordId):
            return [
                "word_id": wordId
            ]
        case .loveChallenge(let challengeId):
            return [
                "challenge_id": challengeId
            ]
        case .unloveChallenge(let challengeId):
            return [
                "challenge_id": challengeId
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
        case .createChallengeOpen,
             .createChallengeDirect,
             .confirmDirect,
             .rejectDirect:
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
        case .createChallengeDirect(let (statement, source, timeAt, timeLimit, topic, screenName, inviteId)):
            var multipartFormData = [MultipartFormData]()
            multipartFormData.append(buildMultipartFormData(key: "statement", value: statement))
            multipartFormData.append(buildMultipartFormData(key: "statement_source", value: source))
            multipartFormData.append(buildMultipartFormData(key: "show_time_at", value: timeAt))
            multipartFormData.append(buildMultipartFormData(key: "time_limit", value: "\(timeLimit)"))
            multipartFormData.append(buildMultipartFormData(key: "topic_list", value: topic))
            multipartFormData.append(buildMultipartFormData(key: "screen_name", value: screenName))
            multipartFormData.append(buildMultipartFormData(key: "invitation_id", value: inviteId))
            return multipartFormData
        case .confirmDirect(let id):
            var multipartFormData = [MultipartFormData]()
            multipartFormData.append(buildMultipartFormData(key: "id", value: id))
            return multipartFormData
        case .rejectDirect(let (id, reason)):
            var multipartFormData = [MultipartFormData]()
            multipartFormData.append(buildMultipartFormData(key: "id", value: id))
            multipartFormData.append(buildMultipartFormData(key: "reason_rejected", value: reason))
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
