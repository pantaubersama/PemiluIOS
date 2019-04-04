//
//  WordstadiumCoordinator.swift
//  PantauBersama
//
//  Created by wisnu bhakti on 11/02/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import UIKit
import RxSwift
import Networking
import Common

protocol WordstadiumNavigator {
    func launchProfile(isMyAccount: Bool, userId: String?) -> Observable<Void>
    func launchNotifications() -> Observable<Void>
    func launchBannerInfo(bannerInfo: BannerInfo) -> Observable<Void>
    func launchNote() -> Observable<Void>
    func launchSearch() -> Observable<Void>
    func launchTooltip(type: LiniType) -> Observable<TooltipResult>
    func launchWordstadiumList(progressType: ProgressType, liniType: LiniType) -> Observable<Void>
    func launchChallenge(wordstadium: Challenge) -> Observable<Void>
    func launchLiveChallenge(wordstadium: Challenge) -> Observable<Void>
    func shareChallenge(challenge: Challenge) -> Observable<Void>
}

class WordstadiumCoordinator: BaseCoordinator<Void> {
    
    var navigationController: UINavigationController!
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    override func start() -> Observable<CoordinationResult> {
        let viewController = WordstadiumController()
        let viewModel = WordstadiumViewModel(navigator: self)
        viewController.viewModel = viewModel
        navigationController.setViewControllers([viewController], animated: true)
        return Observable.never()
    }
}

extension WordstadiumCoordinator: WordstadiumNavigator {
    
    func launchProfile(isMyAccount: Bool, userId: String?) -> Observable<Void> {
        let profileCoordinator = ProfileCoordinator(navigationController: navigationController, isMyAccount: isMyAccount, userId: userId)
        return coordinate(to: profileCoordinator)
    }
    
    func launchNotifications() -> Observable<Void> {
        let notificationCoordinator = NotificationCoordinator(navigationController: navigationController)
        return coordinate(to: notificationCoordinator)
    }
    
    func launchBannerInfo(bannerInfo: BannerInfo) -> Observable<Void> {
        let bannerInfoCoordinator = BannerInfoCoordinator(navigationController: self.navigationController, bannerInfo: bannerInfo)
        return coordinate(to: bannerInfoCoordinator)
    }
    
    func launchNote() -> Observable<Void> {
        let catatanCoordinator = CatatanCoordinator(navigationController: navigationController)
        return coordinate(to: catatanCoordinator)
    }
    
    func launchSearch() -> Observable<Void> {
        let searchCoordinator = SearchCoordinator(navigationController: self.navigationController)
        return coordinate(to: searchCoordinator)
    }
    
    func launchTooltip(type: LiniType) -> Observable<TooltipResult> {
        let tooltipCoordinator = TooltipCoordinator(navigationController: navigationController, liniType: type)
        return coordinate(to: tooltipCoordinator)
    }
    
    func launchWordstadiumList(progressType: ProgressType, liniType: LiniType) -> Observable<Void> {
        let listCoordinator = WordstadiumListCoordinator(navigationController: navigationController, progressType: progressType, liniType: liniType)
        return coordinate(to: listCoordinator)
    }
    
    func launchChallenge(wordstadium: Challenge) -> Observable<Void> {
        let challengeCoordinator = ChallengeCoordinator(navigationController: navigationController, data: wordstadium)
        return coordinate(to: challengeCoordinator)
    }
    
    func launchLiveChallenge(wordstadium: Challenge) -> Observable<Void> {
        let liveDebatCoordinator = LiveDebatCoordinator(navigationController: navigationController, challenge: wordstadium)
        return coordinate(to: liveDebatCoordinator)
    }
    
    func shareChallenge(challenge: Challenge) -> Observable<Void> {
        var wordingShare: String = ""
        switch challenge.progress {
        case .liveNow:
            let wordShare = "[LIVE NOW] 😱 BREAKING! Ada debat seru sedang berlangsung. Wajib disimak sekarang dong, Boskuu~ \(AppContext.instance.infoForKey("URL_WEB_SHARE"))/share/wordstadium/\(challenge.id)"
            wordingShare = wordShare
        case .comingSoon:
            let wordShare = "[COMING SOON] 📌 Ini nih debat yang harus kamu catat jadwalnya. Jangan lewatkan adu argumentasinya, yaa! 🥁 \(AppContext.instance.infoForKey("URL_WEB_SHARE"))/share/wordstadium/\(challenge.id)"
            wordingShare = wordShare
        case .done:
            let wordShare = "[DEBAT DONE] Debat sudah selesai. Coba direview mana yang bagus aja dan mana yang bagus banget 😌👏 \(AppContext.instance.infoForKey("URL_WEB_SHARE"))/share/wordstadium/\(challenge.id)"
            wordingShare = wordShare
        case .waitingOpponent, .waitingConfirmation:
            switch challenge.type {
            case .openChallenge:
                switch challenge.condition {
                case .ongoing:
                    let wordShare = "[OPEN CHALLENGE] Whoaa! Ada yang Open Challenge untuk adu argumentasi nih. Siapa siap? Tap tap and show up! 📢💦 \(AppContext.instance.infoForKey("URL_WEB_SHARE"))/share/wordstadium/\(challenge.id)"
                    wordingShare = wordShare
                case .expired:
                    let wordShare = "[EXPIRED CHALLENGE] So sad to announce that the challenge is expired. Do you have an Eye of Agamotto? 👀 \(AppContext.instance.infoForKey("URL_WEB_SHARE"))/share/wordstadium/\(challenge.id)"
                    wordingShare = wordShare
                default: return Observable.empty()
                }
            case .directChallenge:
                switch challenge.condition {
                case .ongoing:
                    let wordShare = "[DIRECT CHALLENGE] There is a podium for you, Master. Would you sharpen your (s)word? It's a Direct Challenge! 😎✨ \(AppContext.instance.infoForKey("URL_WEB_SHARE"))/share/wordstadium/\(challenge.id)"
                    wordingShare = wordShare
                case .rejected:
                    let wordShare = "[DENIED CHALLENGE] Ah.. The challenge has been denied. Storm can come up anytime, but maybe a flag just stand in the wrong place at the wrong time. Try again soon, Warrior! ✊⚡️ \(AppContext.instance.infoForKey("URL_WEB_SHARE"))/share/wordstadium/\(challenge.id)"
                    wordingShare = wordShare
                case .expired:
                    let wordShare = "[EXPIRED CHALLENGE] So sad to announce that the challenge is expired. Do you have an Eye of Agamotto? 👀 \(AppContext.instance.infoForKey("URL_WEB_SHARE"))/share/wordstadium/\(challenge.id)"
                    wordingShare = wordShare
                default: return Observable.empty()
                }
            default: return Observable.empty()
            }
        default:
            return Observable.empty()
        }
        let activityViewController = UIActivityViewController(activityItems: [wordingShare as NSString], applicationActivities: nil)
        self.navigationController.present(activityViewController, animated: true, completion: nil)
        return Observable.empty()
    }
}
