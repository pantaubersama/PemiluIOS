//
//  LogoutCoordinator.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 25/12/18.
//  Copyright © 2018 PantauBersama. All rights reserved.
//

import Foundation
import RxSwift
import Common
import Networking

enum LogoutType {
    case cancel
    case logout
}

class LogoutCoordinator: BaseCoordinator<LogoutType> {
    private let navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    override func start() -> Observable<CoordinationResult> {
        return Observable<LogoutType>.create({ [weak self](observer) -> Disposable in
            let alert = UIAlertController(title: "Anda yakin ?", message: "Apakah anda yakin keluar dari aplikasi.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Batal", style: .cancel, handler: { (_) in
                observer.onNext(LogoutType.cancel)
                observer.on(.completed)
            }))
            alert.addAction(UIAlertAction(title: "Ya", style: .default, handler: { (_) in
                observer.onNext(LogoutType.logout)
                observer.on(.completed)
            }))
            DispatchQueue.main.async {
                self?.navigationController.present(alert, animated: true, completion: nil)
            }
            return Disposables.create()
        })
            .filter({ $0 == .logout })
            .mapToVoid()
            .flatMap({ [weak self] (_) -> Observable<LogoutType> in
                // TODO: Reset All Account Sosmed and User Defaults Account
                guard let `self` = self else { return Observable.empty() }
                return self.logoutSosmed()
            })
    }
    
    private func logoutSosmed() -> Observable<LogoutType> {
        let facebook = NetworkService.instance
            .requestObject(
                PantauAuthAPI
                    .accountDisconnect(type: "facebook"),
                c: BaseResponse<AccountResponse>.self)
            .asObservable()
            .catchErrorJustComplete()
            .mapToVoid()
        let twitter = NetworkService.instance
            .requestObject(
                PantauAuthAPI
                    .accountDisconnect(type: "twitter"),
                c: BaseResponse<AccountResponse>.self)
            .asObservable()
            .catchErrorJustComplete()
            .mapToVoid()
        return Observable.merge(facebook,
                                twitter)
            .do(onNext: { () in
                // TODO: Remove all account 
                UserDefaults.Account.reset()
                KeychainService.remove(type: NetworkKeychainKind.token)
                KeychainService.remove(type: NetworkKeychainKind.refreshToken)
            })
            .map({ LogoutType.logout })
            .asObservable()
    }
}
