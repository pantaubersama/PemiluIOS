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
    case directChallenge = "DirectChallenge"
    case unknown
    
    public var title: String? {
        switch self {
        case .openChallenge:
            return "Open Challenge"
        case .directChallenge:
            return "Direct Challenge"
        default:
            return nil
        }
    }
    
    public static func type(title: String?) -> ChallengeType {
        guard let title = title else { return .unknown }
        switch title {
        case "Open Challenge":
            return .openChallenge
        case "Direct Challenge":
            return .directChallenge
        default:
            return .unknown
        }
    }
}

public enum ChallengeProgress: String, Codable {
    case waitingOpponent = "waiting_opponent"
    case waitingConfirmation = "waiting_confirmation"
    case comingSoon = "coming_soon"
    case liveNow = "live_now"
    case done = "done"
    case unknown
    
    public var title: String? {
        switch self {
        case .waitingOpponent:
            return "Waiting Opponent"
        case .waitingConfirmation:
            return "Waiting Confirmation"
        case .comingSoon:
            return "Coming Soon"
        case .liveNow:
            return "Live Now"
        case .done:
            return "Done"
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
        case "Coming Soon":
            return .comingSoon
        case "Live Now":
            return .liveNow
        case "Done":
            return .done
        default:
            return .unknown
        }
    }
}

public enum ChallengeCondition: String, Codable {
    case ongoing = "ongoing"
    case expired = "expired"
    case rejected = "rejected"
    case unknown
    
    public var title: String? {
        switch self {
        case .ongoing:
            return "Ongoing"
        case .expired:
            return "Expired"
        case .rejected:
            return "Rejected"
        default:
            return nil
        }
    }
    
    public static func type(title: String?) -> ChallengeCondition {
        guard let title = title else { return .unknown }
        switch title {
        case "Ongoing":
            return .ongoing
        case "Expired":
            return .expired
        case "Rejected":
            return .rejected
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

