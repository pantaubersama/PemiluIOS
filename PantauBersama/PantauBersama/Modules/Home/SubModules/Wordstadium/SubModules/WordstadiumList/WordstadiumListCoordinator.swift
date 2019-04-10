//
//  WordstadiumListCoordinator.swift
//  PantauBersama
//
//  Created by wisnu bhakti on 15/02/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import RxSwift
import Networking
import Common

protocol WordstadiumListNavigator {
    var finish: Observable<Void>! { get set }
    func openChallenge(challenge: Challenge) -> Observable<ChallengeDetailResult>
    func shareChallenge(challenge: Challenge) -> Observable<Void>
}


final class WordstadiumListCoordinator: BaseCoordinator<Void> {
    
    private let navigationController: UINavigationController
    private let progressType: ProgressType
    private let liniType: LiniType
    var finish: Observable<Void>!
    
    init(navigationController: UINavigationController, progressType: ProgressType, liniType: LiniType) {
        self.navigationController = navigationController
        self.progressType = progressType
        self.liniType = liniType
    }
    
    override func start() -> Observable<Void> {
        let viewModel = WordstadiumListViewModel(navigator: self, progress: progressType, liniType: liniType)
        let viewController = WordstadiumListViewController()
        viewController.viewModel = viewModel
        viewController.hidesBottomBarWhenPushed = true
        navigationController.pushViewController(viewController, animated: true)
        return finish.do(onNext: { [weak self] (_) in
            self?.navigationController.popViewController(animated: true)
        })
    }
    
}

extension WordstadiumListCoordinator: WordstadiumListNavigator {
    func openChallenge(challenge: Challenge) -> Observable<ChallengeDetailResult> {
        switch challenge.progress {
        case .waitingConfirmation,
             .waitingOpponent,
             .comingSoon:
            let challengeCoordinator = ChallengeCoordinator(navigationController: navigationController, data: challenge)
            return coordinate(to: challengeCoordinator)
        case .liveNow:
            let debatLiveCoordinator = LiveDebatCoordinator(navigationController: self.navigationController, challenge: challenge)
            return coordinate(to: debatLiveCoordinator)
        default:
            return Observable.empty()
        }
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
