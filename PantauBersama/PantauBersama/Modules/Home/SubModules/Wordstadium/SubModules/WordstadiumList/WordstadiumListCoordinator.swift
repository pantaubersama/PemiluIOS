//
//  WordstadiumListCoordinator.swift
//  PantauBersama
//
//  Created by wisnu bhakti on 15/02/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import RxSwift
import Networking


protocol WordstadiumListNavigator {
    var finish: Observable<Void>! { get set }
    func openChallenge(challenge: Challenge) -> Observable<Void>
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
    func openChallenge(challenge: Challenge) -> Observable<Void> {
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
}
