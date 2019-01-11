//
//  SettingCoordinator.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 22/12/18.
//  Copyright © 2018 PantauBersama. All rights reserved.
//

import UIKit
import RxSwift
import Networking

enum UndangCluster {
    case cancel
    case buat(item: ResultRequest)
}

protocol SettingNavigator {
    var finish: Observable<Void>! { get set }
    func launchProfileEdit(data: User, type: ProfileHeaderItem) -> Observable<Void>
    func launchSignOut() -> Observable<Void>
    func launchBadge() -> Observable<Void>
    func launchVerifikasi(user: VerificationsResponse.U) -> Observable<Void>
    func launchUndang(data: User) -> Observable<Void>
    func launchAlertUndang() -> Observable<Void>
    func launchReqCluster() -> Observable<ResultRequest>
    func launchAlertCluster() -> Observable<Void>
}

final class SettingCoordinator: BaseCoordinator<Void> {
    
    private let navigationController: UINavigationController!
    var finish: Observable<Void>!
    private var data: User
    
    init(navigationController: UINavigationController, data: User) {
        self.navigationController = navigationController
        self.data = data
    }
    
    override func start() -> Observable<CoordinationResult> {
        let viewController = SettingController()
        let viewModel = SettingViewModel(navigator: self, data: data)
        viewController.viewModel = viewModel
        viewController.hidesBottomBarWhenPushed = true
        navigationController.pushViewController(viewController, animated: true)
        return finish.do(onNext: { [weak self] (_) in
            self?.navigationController.popViewController(animated: true)
        })
    }
    
}

extension SettingCoordinator: SettingNavigator {
    func launchProfileEdit(data: User, type: ProfileHeaderItem) -> Observable<Void> {
        let profileEditCoordinator = ProfileEditCoordinator(navigationController: navigationController, data: data, type: type)
        return coordinate(to: profileEditCoordinator)
    }
    
    func launchSignOut() -> Observable<Void> {
        let logoutCoordinator = LogoutCoordinator(navigationController: navigationController)
        return coordinate(to: logoutCoordinator)
            .filter({ $0 == .logout })
            .mapToVoid()
            .flatMap({ [weak self] (_) -> Observable<Void> in
                guard let `self` = self else { return Observable.empty() }
                return self.launchOnboarding()
            })
        
    }
    
    func launchOnboarding() -> Observable<Void> {
        if let app = UIApplication.shared.delegate as? AppDelegate, let window = app.window {
            let appCoordinator = AppCoordinator(window: window)
            return self.coordinate(to: appCoordinator)
        }
        return Observable.empty()
    }
    
    func launchBadge() -> Observable<Void> {
        let badgeCoordinator = BadgeCoordinator(navigationController: navigationController)
        return coordinate(to: badgeCoordinator)
    }
    
    func launchVerifikasi(user: VerificationsResponse.U) -> Observable<Void> {
        switch user.nextStep {
        case 1:
            let identitasCoordinator = IdentitasCoordinator(navigationController: navigationController)
            return coordinate(to: identitasCoordinator)
        case 2:
            let selfIdentitasCoordinator = SelfIdentitasCoordinator(navigationController: navigationController)
            return coordinate(to: selfIdentitasCoordinator)
        case 3:
            let ktpCoordinator = KTPCoordinator(navigationController: navigationController)
            return coordinate(to: ktpCoordinator)
        case 4:
            let signatureCoordinator = SignatureCoordinator(navigationController: navigationController)
            return coordinate(to: signatureCoordinator)
        case 5:
            let successCoordinator = SuccessCoordinator(navigationController: navigationController)
            return coordinate(to: successCoordinator)
        default :
            let identitasCoordinator = IdentitasCoordinator(navigationController: navigationController)
            return coordinate(to: identitasCoordinator)
        }
    }
    
    func launchUndang(data: User) -> Observable<Void> {
        let undangCoordinator = UndangAnggotaCoordinator(navigationController: navigationController, data: data)
        return coordinate(to: undangCoordinator)
    }
    
    func launchAlertUndang() -> Observable<Void> {
        return Observable<UndangCluster>.create({ [weak self] (observer) -> Disposable in
            let alert = UIAlertController(title: "Anda belum memiliki Cluster", message: "Apakah anda ingin request buat Cluster?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Batal", style: .cancel, handler: { (_) in
                observer.onNext(UndangCluster.cancel)
                observer.on(.completed)
            }))
            alert.addAction(UIAlertAction(title: "Ya", style: .default
                , handler: { (_) in
                    observer.onNext(UndangCluster.buat(item: ResultRequest.create))
                    observer.on(.completed)
            }))
            DispatchQueue.main.async {
                self?.navigationController.present(alert, animated: true, completion: nil)
            }
            return Disposables.create()
        })
        .flatMapLatest({ (undang) -> Observable<ResultRequest> in
            switch undang {
            case .buat(item: ResultRequest.create):
                return self.launchReqCluster()
            default: return Observable.empty()
            }
        })
        .mapToVoid()
    }
    
    func launchReqCluster() -> Observable<ResultRequest> {
        let reqClusterCoordinator = ReqClusterCoordinator(navigationController: navigationController)
        return coordinate(to: reqClusterCoordinator)
    }
    
    func launchAlertCluster() -> Observable<Void> {
        return Observable<ClusterOption>.create({ [weak self] (observer) -> Disposable in
            let alert = UIAlertController(title: nil, message: "Anda bukan moderator atau admin dari Cluster ini", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Oke", style: .default
                , handler: { (_) in
                    observer.onNext(.done)
                    observer.on(.completed)
            }))
            DispatchQueue.main.async {
                self?.navigationController.present(alert, animated: true, completion: nil)
            }
            return Disposables.create()
        }).mapToVoid()
    }
}
