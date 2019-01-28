//
//  Parser.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 28/01/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import Foundation
import UserNotifications
import RxSwift


final class Parser {
    
    enum NotifType: String {
        case broadcasts
        case janpol = "janji_politik"
        case feed
        case profile
        case question
        case quiz
    }
    
    enum EventType: String {
        // broadcast
        case activity
        // janpol / pilpres report
        case report
        // profile
        case failedVerification = "gagal_verifikasi"
        case successVerification = "berhasil_verifikasi"
        case successReqCluster = "request_claster_approved"
        case failedReqCluster = "request_claster_rejected"
        case inviteCluster = "cluster_invited"
        case badgeTanya = "badge_tanya"
        case badgeKuis = "badge_kuis"
        case badgeLapor = "badge_lapor"
        case badgeJanpol = "badge_janji_politik"
        case badgeTanyaInteraksi = "badge_tanya_interaksi"
        case badgeProfile = "badge_profile"
        case badgeRelawan = "badge_relawan"
        case badgePantau = "badge_pantau_bersama"
        // question
        case upvoteReport = "upvote_repot"
        case upvote = "upvote"
        // quiz
        case createQuiz = "created_quiz"
    }
    
    
    class func parser(userInfo: [AnyHashable: Any], active: BooleanLiteralType) {
        print("User info: \(userInfo)")
//        guard let notifType = userInfo["notif_type"] as? String,
//        let _notifType = NotifType(rawValue: notifType),
//        let eventType = userInfo["event_type"] as? String,
//        let _eventType = EventType(rawValue: eventType),
//        let payload = userInfo["data"] as? String,
//        let data = payload.data(using: .utf8) else { return }
        
    }
}
