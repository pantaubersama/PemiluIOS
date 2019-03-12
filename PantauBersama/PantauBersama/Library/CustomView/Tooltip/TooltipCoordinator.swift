//
//  TooltipCoordinator.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 12/02/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import RxSwift
import Networking

protocol TooltipNavigator {
    func launchChallenge() -> Observable<Void>
    func launchDebatDone() -> Observable<Void>
    func launchComingSoon() -> Observable<Void>
    func launchDebatLive() -> Observable<Void>
    func launchTantangan() -> Observable<Void>
    func back() -> Observable<Void>
}

final class TooltipCoordinator: BaseCoordinator<TooltipResult> {
    
    private let navigationController: UINavigationController!
    private let viewController: TooltipView
    private let liniType: LiniType
    
    init(navigationController: UINavigationController, liniType: LiniType) {
        self.navigationController = navigationController
        self.viewController = TooltipView()
        self.liniType = liniType
    }
    
    override func start() -> Observable<CoordinationResult> {
        let viewModel = TooltipViewModel(navigator: self)
        let viewController = TooltipView()
        viewController.viewModel = viewModel
        viewController.providesPresentationContextTransitionStyle = true
        viewController.definesPresentationContext = true
        viewController.modalPresentationStyle = UIModalPresentationStyle.overFullScreen
        viewController.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        navigationController.present(viewController, animated: true, completion: nil)
        return viewModel.output.actionsSelected
            .asObservable()
            .take(1)
            .do(onNext: { [weak self] (_) in
                 self?.navigationController.dismiss(animated: true, completion: nil)
            })
    }
    
}


extension TooltipCoordinator: TooltipNavigator {
    func launchChallenge() -> Observable<Void> {
        self.navigationController.dismiss(animated: true, completion: nil)
        let wordstadiumListCoordinator = WordstadiumListCoordinator(navigationController: navigationController, progressType: .challenge, liniType: self.liniType)
        return coordinate(to: wordstadiumListCoordinator)
    }
    
    func launchDebatDone() -> Observable<Void> {
        self.navigationController.dismiss(animated: true, completion: nil)
        let wordstadiumListCoordinator = WordstadiumListCoordinator(navigationController: navigationController, progressType: .done, liniType: self.liniType)
        return coordinate(to: wordstadiumListCoordinator)
    }
    
    func launchComingSoon() -> Observable<Void> {
        self.navigationController.dismiss(animated: true, completion: nil)
        let wordstadiumListCoordinator = WordstadiumListCoordinator(navigationController: navigationController, progressType: .comingSoon, liniType: self.liniType)
        return coordinate(to: wordstadiumListCoordinator)
    }
    
    func launchDebatLive() -> Observable<Void> {
        self.navigationController.dismiss(animated: true, completion: nil)
        let wordstadiumListCoordinator = WordstadiumListCoordinator(navigationController: navigationController, progressType: .liveNow, liniType: self.liniType)
        return coordinate(to: wordstadiumListCoordinator)
    }
    
    func launchTantangan() -> Observable<Void> {
        self.navigationController.dismiss(animated: true, completion: nil)
        let createTantanganCoordinator = CreateTantanganCoordinator(navigationController: navigationController)
        return coordinate(to: createTantanganCoordinator)
    }
    
    func back() -> Observable<Void> {
        let root = UIApplication.shared.keyWindow?.rootViewController
        root?.dismiss(animated: true, completion: nil)
        return Observable.empty()
    }
}
