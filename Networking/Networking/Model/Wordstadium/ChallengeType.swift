//
//  ChallengeType.swift
//  Networking
//
//  Created by wisnu bhakti on 25/02/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import Foundation

public enum ChallengeType: String, Codable {
    case openChallenge = "OpenChallenge"
    case unknown
    
    public var title: String? {
        switch self {
        case .openChallenge:
            return "Open Challenge"
        default:
            return nil
        }
    }
    
    public static func type(title: String?) -> ChallengeType {
        guard let title = title else { return .unknown }
        switch title {
        case "Open Challenge":
            return .openChallenge
        default:
            return .unknown
        }
    }
}

public enum ChallengeProgress: String, Codable {
    case waitingOpponent = "waiting_opponent"
    case waitingConfirmation = "waiting_confirmation"
    case unknown
    
    public var title: String? {
        switch self {
        case .waitingOpponent:
            return "Waiting Opponent"
        case .waitingConfirmation:
            return "Waiting Confirmation"
        default:
            return nil
        }
    }
    
    public static func type(title: String?) -> ChallengeProgress {
        guard let title = title else { return .unknown }
        switch title {
        case "Waiting Opponent":
            return .waitingOpponent
        case "Waiting Confirmation":
            return .waitingConfirmation
        default:
            return .unknown
        }
    }
}

public enum ChallengeCondition: String, Codable {
    case ongoing = "ongoing"
    case unknown
    
    public var title: String? {
        switch self {
        case .ongoing:
            return "Ongoing"
        default:
            return nil
        }
    }
    
    public static func type(title: String?) -> ChallengeCondition {
        guard let title = title else { return .unknown }
        switch title {
        case "Ongoing":
            return .ongoing
        default:
            return .unknown
        }
    }
}

public enum LiniType {
    case `public`
    case personal
    
    public var url: String {
        switch self {
        case .personal:
            return "me"
        case .public:
            return "all"
        }
    }
}

