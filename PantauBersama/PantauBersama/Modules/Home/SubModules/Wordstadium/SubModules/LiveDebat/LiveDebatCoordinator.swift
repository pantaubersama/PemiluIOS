//
//  LiveDebatCoordinator.swift
//  PantauBersama
//
//  Created by Rahardyan Bisma Setya Putra on 12/02/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import Foundation
import Common
import RxSwift
import RxCocoa
import Networking

public protocol LiveDebatNavigator {
    func back() -> Observable<Void>
    func launchDetail(challenge: Challenge) -> Observable<Void>
    func showComment() -> Observable<Void>
}

public enum DebatViewType {
    case watch
    case myTurn
    case theirTurn
    case done
    case participant
}

class LiveDebatCoordinator: BaseCoordinator<ChallengeDetailResult> {
    private let navigationController: UINavigationController
    private let challenge: Challenge
    
    init(navigationController: UINavigationController, challenge: Challenge) {
        self.navigationController = navigationController
        self.challenge = challenge
    }
    
    override func start() -> Observable<ChallengeDetailResult> {
        let viewController = LiveDebatController()
        let viewModel = LiveDebatViewModel(navigator: self, challenge: self.challenge)
        viewController.hidesBottomBarWhenPushed = true
        viewController.viewModel = viewModel
        
        navigationController.pushViewController(viewController, animated: true)
        return Observable.just(ChallengeDetailResult.cancel(isChange: false))
    }
}

extension LiveDebatCoordinator: LiveDebatNavigator {
    func back() -> Observable<Void> {
        self.navigationController.popViewController(animated: true)
        return Observable.never()
    }
    
    func launchDetail(challenge: Challenge) -> Observable<Void> {
        let debatDetailCoordinator = DebatDetailCoordinator(navigationController: self.navigationController, challenge: challenge)
        return coordinate(to: debatDetailCoordinator)
    }
    
    func showComment() -> Observable<Void> {
        let debatCommentCoordinator = DebatCommentCoordinator(navigationController: self.navigationController, challenge: self.challenge)
        return coordinate(to: debatCommentCoordinator)
    }
}
