//
//  ChallengeCoordinator.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 15/02/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import RxSwift
import Networking

protocol ChallengeNavigator {
    func back() -> Observable<Void>
    func openLiveDebatDone() -> Observable<Void>
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
//        viewController.type = type
        viewController.viewModel = viewModel
        viewController.hidesBottomBarWhenPushed = true
        navigationController.pushViewController(viewController, animated: true)
        return Observable.empty()
    }
    
}

extension ChallengeCoordinator: ChallengeNavigator {
    
    func back() -> Observable<Void> {
        navigationController.popViewController(animated: true)
        return Observable.empty()
    }
    
    func openLiveDebatDone() -> Observable<Void> {
        let liveDebatDoneCoordinator = LiveDebatCoordinator(navigationController: self.navigationController, viewType: .done)
        return coordinate(to: liveDebatDoneCoordinator)
    }
}
