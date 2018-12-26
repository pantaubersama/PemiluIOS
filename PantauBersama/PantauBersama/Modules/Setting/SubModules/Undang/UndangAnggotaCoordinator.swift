//
//  UndangAnggotaCoordinator.swift
//  PantauBersama
//
//  Created by wisnu bhakti on 26/12/18.
//  Copyright © 2018 PantauBersama. All rights reserved.
//

import RxSwift
import RxCocoa

protocol UndangAnggotaNavigator {
    var finish: Observable<Void>! { get set }
}

class UndangAnggotaCoordinator : BaseCoordinator<Void>, UndangAnggotaNavigator {
    var finish: Observable<Void>!
    
    private let navigationController: UINavigationController
    
    // TODO: replace any with Quiz model
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    override func start() -> Observable<CoordinationResult> {
        let viewController = UndangAnggotaController()
        let viewModel = UndangAnggotaViewModel(navigator: self)
        viewController.viewModel = viewModel
        viewController.hidesBottomBarWhenPushed = true
        navigationController.pushViewController(viewController, animated: true)
        return finish.do(onNext: { [weak self] (_) in
            self?.navigationController.popViewController(animated: true)
        })
    }
    
}
