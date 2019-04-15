//
//  InputC1Coordinator.swift
//  PantauBersama
//
//  Created by Nanang Rafsanjani on 06/03/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import Common
import RxSwift
import RxCocoa
import Networking

protocol C1InputFormNavigator {
    func back() -> Observable<Void>
    func showSuccess() -> Observable<Void>
}

class C1InputFormCoordinator: BaseCoordinator<Void> {
    private let navigationController: UINavigationController
    private let type: FormC1Type
    private let realCount: RealCount
    private let tingkat: TingkatPemilihan
    
    init(navigationController: UINavigationController, type: FormC1Type, realCount: RealCount, tingkat: TingkatPemilihan) {
        self.type = type
        self.navigationController = navigationController
        self.realCount = realCount
        self.tingkat = tingkat
    }
    
    override func start() -> Observable<Void> {
        let viewController = C1InputFormController()
        let viewModel = C1InputFormViewModel(navigator: self, realCount: self.realCount, tingkat: self.tingkat)
        if self.realCount.status == .sandbox {
            viewController.isSanbox = true
        }
        viewController.viewModel = viewModel
        viewController.hidesBottomBarWhenPushed = true
        viewController.type = type
        
        navigationController.pushViewController(viewController, animated: true)
        return Observable.never()
    }
}

extension C1InputFormCoordinator: C1InputFormNavigator {
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
