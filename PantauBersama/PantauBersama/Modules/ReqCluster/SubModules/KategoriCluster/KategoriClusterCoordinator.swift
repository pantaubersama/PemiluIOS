//
//  KategoriClusterCoordinator.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 05/01/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import RxSwift

protocol KategoriClusterProtocol {
    var finish: Observable<Void>! { get set }
    func launchAdd() -> Observable<Void>
}

final class KategoriClusterCoordinator: BaseCoordinator<Void> {
    
    private let navigationController: UINavigationController!
    var finish: Observable<Void>!
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    override func start() -> Observable<Void> {
        let viewModel = KategoriClusterViewModel(navigator: self)
        let viewController = KategoriClusterController()
        viewController.viewModel = viewModel
        navigationController.pushViewController(viewController, animated: true)
        return finish.do(onNext: { [weak self] (_) in
            self?.navigationController.popViewController(animated: true)
        })
    }
    
}

extension KategoriClusterCoordinator: KategoriClusterProtocol {
    func launchAdd() -> Observable<Void> {
        let addCoordinator = AddKategoriCoordinator(navigationController: navigationController)
        return coordinate(to: addCoordinator)
    }
}
