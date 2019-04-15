//
//  UploadC1Coordinator.swift
//  PantauBersama
//
//  Created by Nanang Rafsanjani on 06/03/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import Common
import RxSwift
import RxCocoa
import Networking

protocol UploadC1Navigator {
    func back() -> Observable<Void>
    func showSuccess() -> Observable<Void>
}

class UploadC1Coordinator: BaseCoordinator<Void> {
    private let navigationController: UINavigationController
    private let realCount: RealCount
    
    init(navigationController: UINavigationController, realCount: RealCount) {
        self.navigationController = navigationController
        self.realCount = realCount
    }
    
    override func start() -> Observable<Void> {
        let viewController = UploadC1Controller()
        let viewModel = UploadC1ViewModel(navigator: self, realCount: self.realCount)
        if self.realCount.status == .sandbox {
            viewController.isSanbox = true
        }
        viewController.viewModel = viewModel
        viewController.hidesBottomBarWhenPushed = true
        
        navigationController.pushViewController(viewController, animated: true)
        return Observable.never()
    }
}

extension UploadC1Coordinator: UploadC1Navigator {
    func back() -> Observable<Void> {
        self.navigationController.popViewController(animated: true)
        return Observable.empty()
    }
    func showSuccess() -> Observable<Void> {
        let alert = UIAlertController(title: "Sukses", message: "Behasil menambahkan data", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Oke", style: .default, handler: { (action) in
            self.navigationController.popViewController(animated: true)
        }))
        navigationController.present(alert, animated: true, completion: nil)
        return Observable.empty()
    }
}
