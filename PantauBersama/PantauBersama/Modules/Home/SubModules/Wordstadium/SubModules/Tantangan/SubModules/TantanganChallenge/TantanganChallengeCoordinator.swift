//
//  TantanganChallengeCoordinator.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 12/02/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import RxSwift
import Networking

protocol TantanganChallengeNavigator {
    var finish: Observable<Void>! { get set }
    func launchBidangKajian() -> Observable<BidangKajianResult>
    func launchHint(type: HintType) -> Observable<Void>
    func launchPernyataanLink() -> Observable<PernyataanLinkResult>
    func launchPublish(type: Bool) -> Observable<Void>
}

final class TantanganChallengeCoordinator: BaseCoordinator<Void> {
    
    private let navigationController: UINavigationController
    var finish: Observable<Void>!
    private var type: Bool
    
    init(navigationController: UINavigationController, type: Bool) {
        self.navigationController = navigationController
        self.type = type
    }
    
    override func start() -> Observable<CoordinationResult> {
        let viewModel = TantanganChallengeViewModel(navigator: self, type: type)
        let viewController = TantanganChallengeController()
        viewController.tantanganType = type
        viewController.viewModel = viewModel
        viewController.hidesBottomBarWhenPushed = true
        navigationController.pushViewController(viewController, animated: true)
        return finish.do(onNext: { [weak self] (_) in
            self?.navigationController.popViewController(animated: true)
        })
    }
    
}

extension TantanganChallengeCoordinator: TantanganChallengeNavigator {
    func launchBidangKajian() -> Observable<BidangKajianResult> {
        let bidangKajian = BidangKajianCoordinator(navigationController: navigationController)
        return coordinate(to: bidangKajian)
    }
    
    func launchHint(type: HintType) -> Observable<Void> {
        let hintTantanganCoordinator = HintTantanganCoordinaot(navigationController: navigationController, type: type)
        return coordinate(to: hintTantanganCoordinator)
    }
    
    func launchPernyataanLink() -> Observable<PernyataanLinkResult> {
        return Observable<PernyataanLinkResult>.create({ [weak self] (observer) -> Disposable in
            let alert = UIAlertController(title: "Input Link", message: "Sertakan tautan/link ke pernyataan kamu", preferredStyle: .alert)
            alert.addTextField(configurationHandler: { (textfield) in
                textfield.placeholder = "Tempelkan di sini..."
            })
            alert.addAction(UIAlertAction(title: "Batal", style: .cancel, handler: { (_) in
                observer.onNext(PernyataanLinkResult.cancel)
                observer.on(.completed)
            }))
            alert.addAction(UIAlertAction(title: "Ya", style: .default, handler: { (_) in
                let textField = alert.textFields![0] // force because its exist
                observer.onNext(PernyataanLinkResult.ok(textField.text ?? ""))
                observer.on(.completed)
            }))
            DispatchQueue.main.async(execute: {
                self?.navigationController.present(alert, animated: true, completion: nil)
            })
            return Disposables.create()
        })
    }
    
    func launchPublish(type: Bool) -> Observable<Void> {
        let publishCoordinator = PublishChallengeCoordinator(navigationController: navigationController, type: type)
        return coordinate(to: publishCoordinator)
    }
}
