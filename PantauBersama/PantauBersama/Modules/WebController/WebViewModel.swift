//
//  WebViewModel.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 02/01/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import RxSwift
import RxCocoa
import Networking
import Common

final class WebViewModel: ViewModelType {
    
    var input: Input
    var output: Output!
    
    struct Input {
        let backI: AnyObserver<Void>
        let codeI: AnyObserver<String>
        let nextI: AnyObserver<Void>
    }
    
    struct Output {
        let url: Driver<String>
        let backO: Driver<Void>
        let nextO: Driver<Void>
    }
    
    private var navigator: WebNavigator
    private var url: String
    private let backS = PublishSubject<Void>()
    private let codeS = PublishSubject<String>()
    private let nextS = PublishSubject<Void>()

    init(navigator: WebNavigator, url: String) {
        self.navigator = navigator
        self.url = url
        
        input = Input(backI: backS.asObserver(),
                      codeI: codeS.asObserver(),
                      nextI: nextS.asObserver())
        
        let back = backS
            .do(onNext: { (_) in
                navigator.back()
            })
            .asDriverOnErrorJustComplete()
        
        
        let nextSelected = codeS
            .flatMapLatest { (code) -> Driver<Void> in
                return NetworkService.instance
                    .requestObject(IdentitasAPI
                        .loginIdentitas(
                            code: code,
                            grantType: "authorization_code",
                            clientId: AppContext.instance.infoForKey("CLIENT_ID"),
                            clientSecret: AppContext.instance.infoForKey("CLIENT_SECRET"),
                            redirectURI: AppContext.instance.infoForKey("REDIRECT_URI")),
                                   c: IdentitasResponses.self)
                    .asObservable()
                    .asDriverOnErrorJustComplete()
                    .flatMapLatest({ self.callBackPantau(provider: $0.accessToken)})
                
        }
        
        output = Output(url: Driver.just(url).asDriver(onErrorJustReturn: ""),
                        backO: back,
                        nextO: nextSelected.asDriverOnErrorJustComplete())
        
    }
    
    private func callBackPantau(provider: String) -> Driver<Void> {
        return NetworkService.instance
            .requestObject(PantauAuthAPI.callback(code: "",
                                                  provider: provider),
                           c: PantauAuthResponse.self)
            .do(onSuccess: { (response) in
                KeychainService.remove(type: NetworkKeychainKind.token)
                KeychainService.remove(type: NetworkKeychainKind.refreshToken)
                print("AccessToken:...\(response.data?.accessToken ?? "")")
                print("RefreshToken:...\(response.data?.refreshToken ?? "")")
                AppState.save(response)
            })
            .asObservable()
            .mapToVoid()
            .do(onNext: { [weak self] (_) in
                guard let `self` = self else { return }
                self.navigator.launchCoordinator()
            })
            .asDriverOnErrorJustComplete()
    }
}
