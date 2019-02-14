//
//  BidangKajianCoordinator.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 12/02/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import RxSwift
import RxCocoa

protocol BidangKajianNavigator {
    
}

final class BidangKajianCoordinator: BaseCoordinator<BidangKajianResult> {
    
    private let navigationController: UINavigationController
    private let viewController: BidangKajianController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
        self.viewController = BidangKajianController()
    }
    
    override func start() -> Observable<CoordinationResult> {
        let viewModel = BidangKajianViewModel(navigator: self)
        let viewController = BidangKajianController()
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

extension BidangKajianCoordinator: BidangKajianNavigator {
    
}
