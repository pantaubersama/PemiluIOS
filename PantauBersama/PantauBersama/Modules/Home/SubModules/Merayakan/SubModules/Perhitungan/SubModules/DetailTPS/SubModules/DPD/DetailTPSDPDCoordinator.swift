//
//  DetailTPSDPDCoordinator.swift
//  PantauBersama
//
//  Created by Nanang Rafsanjani on 06/03/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import Common
import RxSwift
import RxCocoa
import Networking

protocol DetailTPSDPDNavigator {
    func back() -> Observable<Void>
    func showSuccess()
}

class DetailTPSDPDCoordinator: BaseCoordinator<Void> {
    private let navigationController: UINavigationController
    private let data: RealCount
    private let tingkat: TingkatPemilihan
    
    init(navigationController: UINavigationController, data: RealCount, tingkat: TingkatPemilihan) {
        self.navigationController = navigationController
        self.data = data
        self.tingkat = tingkat
    }
    
    override func start() -> Observable<Void> {
        let viewController = DetailTPSDPDController()
        let viewModel = DetailTPSDPDViewModel(navigator: self, data: self.data, tingkat: self.tingkat)
        viewController.viewModel = viewModel
        viewController.hidesBottomBarWhenPushed = true
        
        navigationController.pushViewController(viewController, animated: true)
        return Observable.never()
    }
}

extension DetailTPSDPDCoordinator: DetailTPSDPDNavigator {
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
