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
    func back()
    func launchKategori() -> Observable<Void>
}

final class ReqClusterCoordinator: BaseCoordinator<Void> {
    
    var navigationController: UINavigationController!
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    override func start() -> Observable<CoordinationResult> {
        let viewController = ReqClusterController()
        let viewModel = ReqClusterViewModel(navigator: self)
        viewController.viewModel = viewModel
        navigationController.pushViewController(viewController, animated: true)
        return Observable.never()
    }
    
}

extension ReqClusterCoordinator: ReqClusterNavigator {
    func back() {
        navigationController.popViewController(animated: true)
    }
    
    func launchKategori() -> Observable<Void> {
        let kategoriCoordinator = KategoriClusterCoordinator(navigationController: navigationController)
        return coordinate(to: kategoriCoordinator)
    }
}
