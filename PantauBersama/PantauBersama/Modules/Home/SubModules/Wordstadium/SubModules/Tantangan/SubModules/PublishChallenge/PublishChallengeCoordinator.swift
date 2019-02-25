//
//  PublishChallengeCoordinator.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 14/02/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import RxSwift
import Networking

protocol PublishChallengeNavigator {
    var finish: Observable<Void>! { get set }
    func showSuccess() -> Observable<Void>
}

final class PublishChallengeCoordinator: BaseCoordinator<Void> {
    
    private let navigationController: UINavigationController
    var finish: Observable<Void>!
    var type: Bool
    var challengeModel: ChallengeModel
    
    init(navigationController: UINavigationController, type: Bool, model: ChallengeModel) {
        self.navigationController = navigationController
        self.type = type
        self.challengeModel = model
    }
    
    override func start() -> Observable<Void> {
        let viewModel = PublishChallengeViewModel(navigator: self, type: type, model: challengeModel)
        let viewController = PublishChallengeController()
        viewController.tantanganType = type
        viewController.viewModel = viewModel
        viewController.hidesBottomBarWhenPushed = true
        navigationController.pushViewController(viewController, animated: true)
        return finish.do(onNext: { [weak self] (_) in
            self?.navigationController.popViewController(animated: true)
        })
    }
    
}

extension PublishChallengeCoordinator: PublishChallengeNavigator {
    func showSuccess() -> Observable<Void> {
        let successCoordinator = SuccessPromoteCoordinator(navigationController: navigationController)
        return coordinate(to: successCoordinator)
    }
}
