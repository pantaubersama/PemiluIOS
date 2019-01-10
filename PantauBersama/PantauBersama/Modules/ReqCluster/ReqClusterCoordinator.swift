//
//  ReqClusterCoordinator.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 25/12/18.
//  Copyright © 2018 PantauBersama. All rights reserved.
//

import RxSwift
import RxCocoa


protocol ReqClusterNavigator {
    func launchKategori() -> Observable<ResultCategory>
}

final class ReqClusterCoordinator: BaseCoordinator<ResultRequest> {
    
    var navigationController: UINavigationController!
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    override func start() -> Observable<CoordinationResult> {
        let viewModel = ReqClusterViewModel(navigator: self)
        let viewController = ReqClusterController()
        viewController.viewModel = viewModel
        navigationController.pushViewController(viewController, animated: true)
        return viewModel.output.backO
            .do(onNext: { [weak self] (_) in
                self?.navigationController.popViewController(animated: true)
            })
            .asObservable()
            .take(1)
    }
    
}

extension ReqClusterCoordinator: ReqClusterNavigator {
    
    func launchKategori() -> Observable<ResultCategory> {
        let categoryCoordinator = KategoriClusterCoordinator(navigationController: navigationController)
        return coordinate(to: categoryCoordinator)
    }
    
}
