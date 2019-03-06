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

protocol DetailTPSNavigator {
    func back() -> Observable<Void>
    func sendData() -> Observable<Void>
    func successSubmit() -> Observable<Void>
    func launchDetailTPSPresiden() -> Observable<Void>
    func launchDetailTPSDPRI() -> Observable<Void>
    func launchDetailTPSDPD() -> Observable<Void>
    func launchDetailTPSDPRDKab() -> Observable<Void>
    func launchDetailTPSDPRDProv() -> Observable<Void>
    func launchUploadC1() -> Observable<Void>
    func launchC1Form(type: FormC1Type) -> Observable<Void>
    
}

class DetailTPSCoordinator: BaseCoordinator<Void> {
    private let navigationController: UINavigationController
    private var viewModel: DetailTPSViewModel?
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    override func start() -> Observable<Void> {
        let viewController = DetailTPSController()
        viewModel = DetailTPSViewModel(navigator: self)
        viewController.viewModel = viewModel!
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
    
    func launchDetailTPSPresiden() -> Observable<Void> {
        let searchCoordinator = DetailTPSPresidenCoordinator(navigationController: self.navigationController)
        return coordinate(to: searchCoordinator)
    }
    
    func launchDetailTPSDPRI() -> Observable<Void> {
        let searchCoordinator = DetailTPSDPRCoordinator(navigationController: self.navigationController, type: .DPRRI)
        return coordinate(to: searchCoordinator)
    }
    
    func launchDetailTPSDPD() -> Observable<Void> {
        let searchCoordinator = DetailTPSDPDCoordinator(navigationController: self.navigationController)
        return coordinate(to: searchCoordinator)
    }
    
    func launchDetailTPSDPRDKab() -> Observable<Void> {
        let searchCoordinator = DetailTPSDPRCoordinator(navigationController: self.navigationController, type: .DPRDKota)
        return coordinate(to: searchCoordinator)
    }
    
    func launchDetailTPSDPRDProv() -> Observable<Void> {
        let searchCoordinator = DetailTPSDPRCoordinator(navigationController: self.navigationController, type: .DPRDProv)
        return coordinate(to: searchCoordinator)
    }
    
    func launchUploadC1() -> Observable<Void> {
        let searchCoordinator = UploadC1Coordinator(navigationController: self.navigationController)
        return coordinate(to: searchCoordinator)
    }
    
    func launchC1Form(type: FormC1Type) -> Observable<Void> {
        let searchCoordinator = C1InputFormCoordinator(navigationController: self.navigationController, type: type)
        return coordinate(to: searchCoordinator)
    }
    
    func sendData() -> Observable<Void> {
        if let viewModel = self.viewModel {
            let viewController = SubmitTPSConfirmationController(viewModel: viewModel)
            viewController.modalPresentationStyle = .overCurrentContext
            
            navigationController.present(viewController, animated: true, completion: nil)
        }
        return Observable.never()
    }
}

