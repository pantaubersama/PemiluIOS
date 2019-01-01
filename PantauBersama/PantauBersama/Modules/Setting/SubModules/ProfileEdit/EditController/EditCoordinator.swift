//
//  EditCoordinator.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 01/01/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import RxSwift


protocol EditNavigator {
    var finish: Observable<Void>! { get set }
    func back()
}

final class EditCoordinator: BaseCoordinator<Void> {
    
    
    private let navigationController: UINavigationController
    var finish: Observable<Void>!
    private let item: SectionOfProfileInfoData
    
    init(navigationController: UINavigationController, item: SectionOfProfileInfoData) {
        self.item = item
        self.navigationController = navigationController
    }
    
    override func start() -> Observable<CoordinationResult> {
        let viewModel = EditViewModel(navigator: self, item: item)
        let viewController = EditController()
        viewController.viewModel = viewModel
        navigationController.pushViewController(viewController, animated: true)
        return finish.do(onNext: { [weak self] (_) in
            self?.navigationController.popViewController(animated: true)
        })
    }
}

extension EditCoordinator: EditNavigator {
 
    func back() {
        navigationController.popViewController(animated: true)
    }
    
}
