//
//  DetailTPSCoordinator.swift
//  PantauBersama
//
//  Created by Rahardyan Bisma on 25/02/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import Foundation
import Common
import RxSwift
import RxCocoa
import Networking

protocol DetailTPSNavigator {
    func back() -> Observable<Void>
    func sendData() -> Observable<Void>
    func successSubmit() -> Observable<Void>
    func launchDetailTPSPresiden(data: RealCount) -> Observable<Void>
    func launchDetailTPSDPRI(data: RealCount) -> Observable<Void>
    func launchDetailTPSDPD() -> Observable<Void>
    func launchDetailTPSDPRDKab(data: RealCount) -> Observable<Void>
    func launchDetailTPSDPRDProv(data: RealCount) -> Observable<Void>
    func launchUploadC1(data: RealCount) -> Observable<Void>
    func launchC1Form(type: FormC1Type, data: RealCount, tingkat: TingkatPemilihan) -> Observable<Void>
    
}

class DetailTPSCoordinator: BaseCoordinator<Void> {
    private let navigationController: UINavigationController
    private var viewModel: DetailTPSViewModel?
    private let realCount: RealCount
    
    init(navigationController: UINavigationController, realCount: RealCount) {
        self.navigationController = navigationController
        self.realCount = realCount
    }
    
    override func start() -> Observable<Void> {
        let viewController = DetailTPSController()
        viewModel = DetailTPSViewModel(navigator: self, realCount: realCount)
        viewController.viewModel = viewModel!
        viewController.hidesBottomBarWhenPushed = true
        
        navigationController.pushViewController(viewController, animated: true)
        
        return Observable.never()
    }
}

extension DetailTPSCoordinator: DetailTPSNavigator {
    
    func successSubmit() -> Observable<Void> {
        navigationController.popToRootViewController(animated: true)
        return Observable.never()
    }
    
    func back() -> Observable<Void> {
        navigationController.popViewController(animated: true)
        return Observable.never()
    }
    
    func launchDetailTPSPresiden(data: RealCount) -> Observable<Void> {
        let searchCoordinator = DetailTPSPresidenCoordinator(navigationController: self.navigationController, uuid: data.id)
        return coordinate(to: searchCoordinator)
    }
    
    func launchDetailTPSDPRI(data: RealCount) -> Observable<Void> {
        let searchCoordinator = DetailTPSDPRCoordinator(navigationController: self.navigationController, type: .DPRRI, realCount: data, tingkat: .dpr)
        return coordinate(to: searchCoordinator)
    }
    
    func launchDetailTPSDPD() -> Observable<Void> {
        let searchCoordinator = DetailTPSDPDCoordinator(navigationController: self.navigationController)
        return coordinate(to: searchCoordinator)
    }
    
    func launchDetailTPSDPRDKab(data: RealCount) -> Observable<Void> {
        let searchCoordinator = DetailTPSDPRCoordinator(navigationController: self.navigationController, type: .DPRDKota, realCount: data, tingkat: .kabupaten)
        return coordinate(to: searchCoordinator)
    }
    
    func launchDetailTPSDPRDProv(data: RealCount) -> Observable<Void> {
        let searchCoordinator = DetailTPSDPRCoordinator(navigationController: self.navigationController, type: .DPRDProv, realCount: data, tingkat: .provinsi)
        return coordinate(to: searchCoordinator)
    }
    
    func launchUploadC1(data: RealCount) -> Observable<Void> {
        let searchCoordinator = UploadC1Coordinator(navigationController: self.navigationController, realCount: data)
        return coordinate(to: searchCoordinator)
    }
    
    func launchC1Form(type: FormC1Type, data: RealCount, tingkat: TingkatPemilihan) -> Observable<Void> {
        let searchCoordinator = C1InputFormCoordinator(navigationController: self.navigationController, type: type, realCount: data, tingkat: tingkat)
        return coordinate(to: searchCoordinator)
    }
    
    func sendData() -> Observable<Void> {
        if let viewModel = self.viewModel {
            let viewController = SubmitTPSConfirmationController(viewModel: viewModel)
            viewController.modalPresentationStyle = .overCurrentContext
            viewController.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
            navigationController.present(viewController, animated: true, completion: nil)
        }
        return Observable.never()
    }
}

