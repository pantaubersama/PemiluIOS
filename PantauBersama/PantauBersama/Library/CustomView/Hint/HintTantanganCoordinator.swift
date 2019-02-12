//
//  HintTantanganCoordinator.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 12/02/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import RxSwift

enum HintType {
    case kajian
    case pernyataan
    case lawanDebat
    case dateTime
    case saldoWaktu
}

protocol HintTantantanganNavigator {
    var finish: Observable<Void>! { get set }
}

final class HintTantanganCoordinaot: BaseCoordinator<Void>, HintTantantanganNavigator {
    
    private let navigationController: UINavigationController
    private let type: HintType
    var finish: Observable<Void>!
    init(navigationController: UINavigationController, type: HintType) {
        self.navigationController = navigationController
        self.type = type
    }
    
    override func start() -> Observable<CoordinationResult> {
        let viewModel = HintTantanganViewModel(navigator: self)
        let viewController = HintTantanganView()
        viewController.viewModel = viewModel
        viewController.providesPresentationContextTransitionStyle = true
        viewController.definesPresentationContext = true
        viewController.modalPresentationStyle = UIModalPresentationStyle.overFullScreen
        viewController.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        
        navigationController.present(viewController, animated: true, completion: nil)
        return finish.do(onNext: { [weak self] (_) in
            self?.navigationController.dismiss(animated: true, completion: nil)
        })
    }
    
}
