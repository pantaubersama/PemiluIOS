//
//  OpenChallengeCoordinator.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 12/02/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import RxSwift

protocol OpenChallengeNavigator {
    var finish: Observable<Void>! { get set }
    func launchBidangKajian() -> Observable<BidangKajianResult>
    func launchHint(type: HintType) -> Observable<Void>
}

final class OpenChallengeCoordinator: BaseCoordinator<Void> {
    
    private let navigationController: UINavigationController
    var finish: Observable<Void>!
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    override func start() -> Observable<CoordinationResult> {
        let viewModel = OpenChallengeViewModel(navigator: self)
        let viewController = OpenChallengeController()
        viewController.viewModel = viewModel
        viewController.hidesBottomBarWhenPushed = true
        navigationController.pushViewController(viewController, animated: true)
        return finish.do(onNext: { [weak self] (_) in
            self?.navigationController.popViewController(animated: true)
        })
    }
    
}

extension OpenChallengeCoordinator: OpenChallengeNavigator {
    func launchBidangKajian() -> Observable<BidangKajianResult> {
        let bidangKajian = BidangKajianCoordinator(navigationController: navigationController)
        return coordinate(to: bidangKajian)
    }
    
    func launchHint(type: HintType) -> Observable<Void> {
        let hintTantanganCoordinator = HintTantanganCoordinaot(navigationController: navigationController, type: type)
        return coordinate(to: hintTantanganCoordinator)
    }
}
