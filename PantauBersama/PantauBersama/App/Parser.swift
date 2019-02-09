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
import Networking
import Common
import UIKit

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
    case info
    case event
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

final class Parser {
    
    class func parse(userInfo: [AnyHashable: Any], active: Bool) {
        print("User info: \(userInfo)")
        guard let payload = userInfo["payload"] as? String,
        let data = payload.data(using: .utf8) else { return }
        
        handle(active: active, data: data)
    }
    
    private class func handle(active: Bool, data: Data) {
        do {
            let responsePayload = try JSONDecoder().decode(PayloadResponse.self, from: data)
            if let notifType = NotifType(rawValue: responsePayload.notifType) {
                switch notifType {
                case .broadcasts:
                    print("Notifikasi Broadcast")
                    do {
                        let respondBroadcast = try JSONDecoder().decode(FirebaseBroadcastResponse.self, from: data)
                        if let currentNavigation = UIApplication.topViewController()?.navigationController {
                            var parserCoordinator: ParserCoordinator!
                            let disposeBag = DisposeBag()
                            parserCoordinator = ParserCoordinator(navigationController: currentNavigation, notifType: NotifType.broadcasts, link: respondBroadcast.broadcast.link)
                            parserCoordinator.start()
                                .subscribe()
                                .disposed(by: disposeBag)
                            
                        }
                        
                    } catch let error {
                        print(error.localizedDescription)
                    }
                case .question:
                    do {
                        print("Notifikasi upvote")
                        let responseQuestionNotif = try JSONDecoder().decode(FirebaseQuestionNotifResponse.self, from: data)
                        if let currentNavigation = UIApplication.topViewController()?.navigationController {
                            let detailAskCoordinator = DetailAskCoordinator(navigationController: currentNavigation, data: responseQuestionNotif.question.id)
                            let disposeBag = DisposeBag()
                            
                            detailAskCoordinator.start()
                                .subscribe()
                                .disposed(by: disposeBag)
                            
                        }
                        print(responseQuestionNotif)
                    } catch let error {
                        print(error.localizedDescription)
                    }
                default:
                    break
                }
            }
            
        } catch let error {
            print(error.localizedDescription)
        }
    }
}


extension String {
    var isValidURL: Bool {
        let detector = try! NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
        if let match = detector.firstMatch(in: self, options: [], range: NSRange(location: 0, length: self.endIndex.encodedOffset)) {
            // it is a link, if the match covers the whole string
            return match.range.length == self.endIndex.encodedOffset
        } else {
            return false
        }
    }
}



extension UIApplication {
    class func topViewController(base: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return topViewController(base: nav.visibleViewController)
        }
        if let tab = base as? UITabBarController {
            let moreNavigationController = tab.moreNavigationController
            
            if let top = moreNavigationController.topViewController, top.view.window != nil {
                return topViewController(base: top)
            } else if let selected = tab.selectedViewController {
                return topViewController(base: selected)
            }
        }
        if let presented = base?.presentedViewController {
            return topViewController(base: presented)
        }
        return base
    }
}
