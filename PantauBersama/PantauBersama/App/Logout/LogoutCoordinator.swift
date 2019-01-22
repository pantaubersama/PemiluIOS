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
    private var data: User
    
    init(navigationController: UINavigationController, data: User) {
        self.navigationController = navigationController
        self.data = data
    }
    
    override func start() -> Observable<CoordinationResult> {
        return Observable<LogoutType>.create({ [weak self](observer) -> Disposable in
            let alert = UIAlertController(title: "Keluar Aplikasi", message: "Apakah Anda akan keluar dari aplikasi Pantau Bersama?", preferredStyle: .alert)
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
                // If user have logged in sosmed must reset
                guard let `self` = self else { return Observable.empty() }
                if self.data.twitter == true && self.data.facebook == true {
                    return self.logoutSosmed()
                } else if self.data.facebook == true {
                    return self.logoutFacebook()
                } else if self.data.twitter == true {
                    return self.logoutTwitter()
                } else {
                    // just account
                    UserDefaults.Account.reset()
                    KeychainService.remove(type: NetworkKeychainKind.token)
                    KeychainService.remove(type: NetworkKeychainKind.refreshToken)
                    return Observable.just(LogoutType.logout)
                }
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
    
    private func logoutFacebook() -> Observable<LogoutType> {
        let facebook = NetworkService.instance
            .requestObject(
                PantauAuthAPI
                    .accountDisconnect(type: "facebook"),
                c: BaseResponse<AccountResponse>.self)
            .asObservable()
            .catchErrorJustComplete()
            .mapToVoid()
        return facebook
            .do(onNext: { () in
                // TODO: Remove all account
                UserDefaults.Account.reset()
                KeychainService.remove(type: NetworkKeychainKind.token)
                KeychainService.remove(type: NetworkKeychainKind.refreshToken)
            })
            .map({ LogoutType.logout })
            .asObservable()
    }
    
    private func logoutTwitter() -> Observable<LogoutType> {
        let twitter = NetworkService.instance
            .requestObject(
                PantauAuthAPI
                    .accountDisconnect(type: "twitter"),
                c: BaseResponse<AccountResponse>.self)
            .asObservable()
            .catchErrorJustComplete()
            .mapToVoid()
        return twitter
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
