//
//  UndangAnggotaCoordinator.swift
//  PantauBersama
//
//  Created by wisnu bhakti on 26/12/18.
//  Copyright © 2018 PantauBersama. All rights reserved.
//

import RxSwift
import RxCocoa
import Networking

protocol UndangAnggotaNavigator {
    var finish: Observable<Void>! { get set }
    func success() -> Observable<Void>
}

class UndangAnggotaCoordinator : BaseCoordinator<Void> {
    var finish: Observable<Void>!
    
    private let navigationController: UINavigationController
    private let data: User
    
    init(navigationController: UINavigationController, data: User) {
        self.navigationController = navigationController
        self.data = data
    }
    
    override func start() -> Observable<CoordinationResult> {
        let viewController = UndangAnggotaController()
        let viewModel = UndangAnggotaViewModel(navigator: self, data: data)
        viewController.viewModel = viewModel
        viewController.hidesBottomBarWhenPushed = true
        navigationController.pushViewController(viewController, animated: true)
        return finish.do(onNext: { [weak self] (_) in
            self?.navigationController.popViewController(animated: true)
        })
    }
    
}

extension UndangAnggotaCoordinator: UndangAnggotaNavigator {
    func success() -> Observable<Void> {
        return Observable<Any>.create({ [weak self] (observer) -> Disposable in
            let alert = UIAlertController(title: "Sukses", message: "Behasil menambahkan email", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Oke", style: .default, handler: { (_) in
                observer.onNext(())
                observer.on(.completed)
            }))
            DispatchQueue.main.async {
                self?.navigationController.present(alert, animated: true, completion: nil)
            }
            return Disposables.create()
        }).mapToVoid()
    }
}
