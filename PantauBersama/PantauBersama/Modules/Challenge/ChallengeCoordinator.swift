//
//  ChallengeCoordinator.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 15/02/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import RxSwift
import Networking

enum DeleteChallengeResult {
    case ok(data: String)
    case cancel
}

protocol ChallengeNavigator {
    func back() -> Observable<Void>
    func openLiveDebatDone(challenge: Challenge) -> Observable<Void>
    func openAcceptConfirmation(type: PopupChallengeType) -> Observable<PopupChallengeResult>
    func shareChallenge(challenge: Challenge) -> Observable<Void>
    func deleteChallenge(challengeId: String) -> Observable<DeleteChallengeResult>
}

final class ChallengeCoordinator: BaseCoordinator<Void> {
    
    private let navigationController: UINavigationController
    private var data: Challenge
    
    init(navigationController: UINavigationController, data: Challenge) {
        self.navigationController = navigationController
        self.data = data
    }
    
    override func start() -> Observable<Void> {
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
            .mapToVoid()
    }
    
}

extension ChallengeCoordinator: ChallengeNavigator {
    
    func back() -> Observable<Void> {
        navigationController.popViewController(animated: true)
        return Observable.empty()
    }
    
    func openLiveDebatDone(challenge: Challenge) -> Observable<Void> {
        let liveDebatDoneCoordinator = LiveDebatCoordinator(navigationController: self.navigationController, challenge: challenge)
        return coordinate(to: liveDebatDoneCoordinator)
    }
    
    func openAcceptConfirmation(type: PopupChallengeType) -> Observable<PopupChallengeResult> {
        let popupChallengeCoordinator = PopupChallengeCoordinator(navigationController: self.navigationController, type: type, data: data)
        return coordinate(to: popupChallengeCoordinator)
    }
    
    func shareChallenge(challenge: Challenge) -> Observable<Void> {
        let shareString = "Ayo debat \(challenge.id)"
        let activityViewController = UIActivityViewController(activityItems: [shareString as NSString], applicationActivities: nil)
        self.navigationController.present(activityViewController, animated: true, completion: nil)
        return Observable.never()
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
