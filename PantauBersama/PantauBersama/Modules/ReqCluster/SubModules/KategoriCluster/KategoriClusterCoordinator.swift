//
//  KategoriClusterCoordinator.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 05/01/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import RxSwift
import Networking

protocol KategoriClusterProtocol {
    func launchAdd() -> Observable<AddKategoriResult>
}

final class KategoriClusterCoordinator: BaseCoordinator<ResultCategory> {
    
    private let navigationController: UINavigationController!
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    override func start() -> Observable<CoordinationResult> {
        let viewModel = KategoriClusterViewModel(navigator: self)
        let viewController = KategoriClusterController(viewModel: viewModel)
        viewController.viewModel = viewModel
        navigationController.pushViewController(viewController, animated: true)
        return viewModel.output.resultO
            .asObservable()
            .take(1)
            .do(onNext: { [weak self] (_) in
                self?.navigationController.popViewController(animated: true)
            })
    }
    
}

extension KategoriClusterCoordinator: KategoriClusterProtocol {
    func launchAdd() -> Observable<AddKategoriResult> {
        let addCoordinator = AddKategoriCoordinator(navigationController: navigationController)
        return coordinate(to: addCoordinator)
    }
}
