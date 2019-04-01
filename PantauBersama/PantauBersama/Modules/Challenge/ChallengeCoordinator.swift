//
//  ChallengeCoordinator.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 15/02/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import RxSwift
import Networking
import Common

enum DeleteChallengeResult {
    case ok(data: String)
    case cancel
}

protocol ChallengeNavigator {
    func back() -> Observable<Void>
    func openLiveDebatDone(challenge: Challenge) -> Observable<ChallengeDetailResult>
    func openAcceptConfirmation(type: PopupChallengeType) -> Observable<PopupChallengeResult>
    func shareChallenge(challenge: Challenge) -> Observable<Void>
    func deleteChallenge(challengeId: String) -> Observable<DeleteChallengeResult>
}

final class ChallengeCoordinator: BaseCoordinator<ChallengeDetailResult> {
    
    private let navigationController: UINavigationController
    private var data: Challenge
    
    init(navigationController: UINavigationController, data: Challenge) {
        self.navigationController = navigationController
        self.data = data
    }
    
    override func start() -> Observable<ChallengeDetailResult> {
        let viewController = ChallengeController()
        let viewModel = ChallengeViewModel(navigator: self, data: data)
        viewController.data = data
        viewController.viewModel = viewModel
        viewController.hidesBottomBarWhenPushed = true
        navigationController.pushViewController(viewController, animated: true)
        return viewModel.output.backO.asObservable()
            .take(1)
            .do(onNext: { [unowned self] (_) in
                self.navigationController.popViewController(animated: true)
            })
    }
    
}

extension ChallengeCoordinator: ChallengeNavigator {
    
    func back() -> Observable<Void> {
        navigationController.popViewController(animated: true)
        return Observable.empty()
    }
    
    func openLiveDebatDone(challenge: Challenge) -> Observable<ChallengeDetailResult> {
        let liveDebatDoneCoordinator = LiveDebatCoordinator(navigationController: self.navigationController, challenge: challenge)
        return coordinate(to: liveDebatDoneCoordinator)
    }
    
    func openAcceptConfirmation(type: PopupChallengeType) -> Observable<PopupChallengeResult> {
        let popupChallengeCoordinator = PopupChallengeCoordinator(navigationController: self.navigationController, type: type, data: data)
        return coordinate(to: popupChallengeCoordinator)
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
    
    func deleteChallenge(challengeId: String) -> Observable<DeleteChallengeResult> {
        return Observable<DeleteChallengeResult>.create({ [weak self] (observer) -> Disposable in
            let alert = UIAlertController(title: "Delete Challenge", message: "Apakah Anda yakin untuk menghapus challenge ini?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (_) in
                observer.onNext(DeleteChallengeResult.ok(data: challengeId))
                observer.on(.completed)
            }))
            alert.addAction(UIAlertAction(title: "Batal", style: .cancel, handler: { (_) in
                observer.onNext(DeleteChallengeResult.cancel)
                observer.on(.completed)
            }))
            DispatchQueue.main.async {
                self?.navigationController.present(alert, animated: true, completion: nil)
            }
            return Disposables.create()
        })
    }
}
