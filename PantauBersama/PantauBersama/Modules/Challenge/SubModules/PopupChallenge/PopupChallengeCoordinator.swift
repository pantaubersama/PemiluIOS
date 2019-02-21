//
//  PopupChallengeCoordinator.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 15/02/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import RxSwift

enum PopupChallengeResult {
    case cancel
    case oke(String)
}

protocol PopupChallengeNavigator {
    func back() -> Observable<Void>
}

final class PopupChallengeCoordinator: BaseCoordinator<PopupChallengeResult> {
    
    private let navigationController: UINavigationController
    private let viewController: PopoupChallengeController
    var type: PopupChallengeType = .default
    
    init(navigationController: UINavigationController, type: PopupChallengeType) {
        self.navigationController = navigationController
        self.viewController = PopoupChallengeController()
        self.type = type
    }
    
    override func start() -> Observable<CoordinationResult> {
        let viewModel = PopupChallengeViewModel(navigator: self)
        let viewController = PopoupChallengeController()
        viewController.type = type
        viewController.viewModel = viewModel
        viewController.providesPresentationContextTransitionStyle = true
        viewController.definesPresentationContext = true
        viewController.modalPresentationStyle = UIModalPresentationStyle.overFullScreen
        viewController.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        navigationController.present(viewController, animated: true, completion: nil)
        return viewModel.output.actionSelected
            .asObservable()
            .take(1)
            .do(onNext: { [weak self] (_) in
                self?.navigationController.dismiss(animated: true, completion: nil)
            })
    }
}

extension PopupChallengeCoordinator: PopupChallengeNavigator {
    func back() -> Observable<Void> {
        let root = UIApplication.shared.keyWindow?.rootViewController
        root?.dismiss(animated: true, completion: nil)
        return Observable.empty()
    }
}
