//
//  DetailTPSDPRCoordinator.swift
//  PantauBersama
//
//  Created by Nanang Rafsanjani on 06/03/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import Common
import RxSwift
import RxCocoa
import Networking

protocol DetailTPSDPRNavigator {
    func back() -> Observable<Void>
    func showSuccess()
}

class DetailTPSDPRCoordinator: BaseCoordinator<Void> {
    private let navigationController: UINavigationController
    private let type: TPSDPRType
    private let realCount: RealCount
    private let tingkat: TingkatPemilihan
    
    init(navigationController: UINavigationController, type: TPSDPRType, realCount: RealCount, tingkat: TingkatPemilihan) {
        self.type = type
        self.navigationController = navigationController
        self.realCount = realCount
        self.tingkat = tingkat
    }
    
    override func start() -> Observable<Void> {
        let viewController = DetailTPSDPRController()
        let viewModel = DetailTPSDPRViewModel(navigator: self, realCount: self.realCount, type: self.tingkat)
        if realCount.status == .sandbox {
            viewController.isSanbox = true
        }
        viewController.viewModel = viewModel
        viewController.type = type
        viewController.hidesBottomBarWhenPushed = true
        
        navigationController.pushViewController(viewController, animated: true)
        return Observable.never()
    }
}

extension DetailTPSDPRCoordinator: DetailTPSDPRNavigator {
    func back() -> Observable<Void> {
        self.navigationController.popViewController(animated: true)
        return Observable.empty()
    }
    func showSuccess() {
        let alert = UIAlertController(title: "Sukses", message: "Behasil menambahkan data", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Oke", style: .default, handler: { (action) in
            self.navigationController.popViewController(animated: true)
        }))
        navigationController.present(alert, animated: true, completion: nil)
    }
}
