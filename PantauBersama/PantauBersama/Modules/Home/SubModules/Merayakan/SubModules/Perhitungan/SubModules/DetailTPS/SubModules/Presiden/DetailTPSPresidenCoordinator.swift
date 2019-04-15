//
//  HitungSuaraPresidenCoordinator.swift
//  PantauBersama
//
//  Created by Nanang Rafsanjani on 02/03/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import Common
import RxSwift
import RxCocoa
import Networking

protocol DetailTPSPresidenNavigator {
    func back() -> Observable<Void>
    func showSuccess()
}

class DetailTPSPresidenCoordinator: BaseCoordinator<Void> {
    private let navigationController: UINavigationController
    private let data: RealCount
    
    init(navigationController: UINavigationController, data: RealCount) {
        self.navigationController = navigationController
        self.data = data
    }
    
    override func start() -> Observable<Void> {
        let viewController = DetailTPSPresidenController()
        let viewModel = DetailTPSPresidenViewModel(navigator: self, data: self.data)
        viewController.viewModel = viewModel
        viewController.hidesBottomBarWhenPushed = true
        
        navigationController.pushViewController(viewController, animated: true)
        return Observable.never()
    }
}

extension DetailTPSPresidenCoordinator: DetailTPSPresidenNavigator {
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
