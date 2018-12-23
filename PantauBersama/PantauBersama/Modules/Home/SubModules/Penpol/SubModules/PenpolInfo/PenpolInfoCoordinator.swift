//
//  PenpolInfoCoordinator.swift
//  PantauBersama
//
//  Created by Rahardyan Bisma on 23/12/18.
//  Copyright © 2018 PantauBersama. All rights reserved.
//

import Foundation
import Common
import RxSwift

class PenpolInfoCoordinator: BaseCoordinator<Void> {
    private let navigationController: UINavigationController
    private let infoType: PenpolInfoType
    
    
    init(navigationController: UINavigationController, infoType: PenpolInfoType) {
        self.navigationController = navigationController
        self.infoType = infoType
    }
    override func start() -> Observable<Void> {
        let viewController = PenpolInfoController()
        let viewModel = PenpolInfoViewModel(infoType: infoType)
        viewController.viewModel = viewModel
        
        navigationController.present(viewController, animated: true, completion: nil)
        
        return viewModel.output.finish.do(onNext: { [weak self](_) in
            self?.navigationController.dismiss(animated: true, completion: nil)
        }).asObservable()
    }
    
}
