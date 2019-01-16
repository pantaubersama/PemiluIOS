//
//  CreateAskCoordinator.swift
//  PantauBersama
//
//  Created by wisnu bhakti on 23/12/18.
//  Copyright © 2018 PantauBersama. All rights reserved.
//

import RxSwift
import RxCocoa

protocol CreateAskNavigator {
    var back: Observable<Void>! { get set }
    var createComplete: Observable<Void>! { get set }
}

class CreateAskCoordinator: BaseCoordinator<Void>, CreateAskNavigator {
    var back: Observable<Void>!
    var createComplete: Observable<Void>!
    
    private let navigationController: UINavigationController
    private let loadCreatedTrigger: AnyObserver<Void>
    
    init(navigationController: UINavigationController, loadCreatedTrigger: AnyObserver<Void>) {
        self.navigationController = navigationController
        self.loadCreatedTrigger = loadCreatedTrigger
    }
    
    override func start() -> Observable<CoordinationResult> {
        let viewController = CreateAskController()
        let viewModel = CreateAskViewModel(navigator: self)
        viewController.viewModel = viewModel
        viewController.hidesBottomBarWhenPushed = true
        navigationController.pushViewController(viewController, animated: true)
        
        let backObs = back.do(onNext: { [weak self](_) in
            self?.navigationController.popViewController(animated: true)
        })
        
        let createObs = createComplete.do(onNext: { [weak self](_) in
            DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                self?.navigationController.popViewController(animated: true)
                self?.loadCreatedTrigger.onNext(())
            })
        })
        
        return Observable.merge(backObs, createObs)
    }
    
}
