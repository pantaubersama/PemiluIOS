//
//  KTPCoordinator.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 30/12/18.
//  Copyright © 2018 PantauBersama. All rights reserved.
//

import RxCocoa
import RxSwift

protocol KTPNavigator {
    var finish: Observable<Void>! { get set }
    func launchSignature() -> Observable<Void>
}

class KTPCoordinator: BaseCoordinator<Void> {
    
    private let navigationController: UINavigationController
    var finish: Observable<Void>!
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    override func start() -> Observable<CoordinationResult> {
        let viewModel = KTPViewModel(navigator: self)
        let viewController = KTPController()
        viewController.viewModel = viewModel
        navigationController.pushViewController(viewController, animated: true)
        return finish.do(onNext: { [weak self] (_) in
            self?.navigationController.popViewController(animated: true)
        })
    }
}

extension KTPCoordinator: KTPNavigator {
    func launchSignature() -> Observable<Void> {
        let signatureCoordinator = SignatureCoordinator(navigationController: navigationController)
        return coordinate(to: signatureCoordinator)
    }
    
    
}
