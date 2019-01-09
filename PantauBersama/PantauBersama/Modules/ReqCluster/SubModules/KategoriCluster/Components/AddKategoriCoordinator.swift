//
//  AddKategoriCoordinator.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 09/01/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import Foundation
import RxSwift

protocol AddKategoriNavigator {
    func back() -> Observable<Void>
}

final class AddKategoriCoordinator: BaseCoordinator<Void> {
    
    private let navigationController: UINavigationController
    private let viewController: AddKategoriController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
        self.viewController = AddKategoriController()
    }
    
    override func start() -> Observable<Void> {
        let viewModel = AddKategoriViewModel(navigator: self)
        let viewController = AddKategoriController()
        viewController.viewModel = viewModel
        viewController.providesPresentationContextTransitionStyle = true
        viewController.definesPresentationContext = true
        viewController.modalPresentationStyle = UIModalPresentationStyle.overFullScreen
        viewController.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        navigationController.present(viewController, animated: true, completion: nil)
        return Observable.empty()
    }
    
}

extension AddKategoriCoordinator: AddKategoriNavigator {
    func back() -> Observable<Void> {
        let root = UIApplication.shared.keyWindow?.rootViewController
        root?.dismiss(animated: true, completion: nil)
        return Observable.empty()
    }
}
