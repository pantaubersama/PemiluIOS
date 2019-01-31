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
        
        
        let errorTracker = ErrorTracker()
        let activityIndicator = ActivityIndicator()
        
        let back = backS
            .do(onNext: { (_) in
                navigator.back()
            })
            .asDriverOnErrorJustComplete()
        
        // MARK
        // Get user data from cloud and checking local
        let local: Observable<UserResponse> = AppState.local(key: .me)
        let cloud = NetworkService.instance
            .requestObject(PantauAuthAPI.me,
                           c: BaseResponse<UserResponse>.self)
            .map({ $0.data })
            .trackError(errorTracker)
            .trackActivity(activityIndicator)
            .asObservable()
            .catchErrorJustComplete()
        // merge local and cloud
        let userData = Observable.merge(local, cloud)
        
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
                    .flatMapLatest({ self.callBackPantau(provider: $0.accessToken, user: userData)})
                
        }
        
        output = Output(url: Driver.just(url).asDriver(onErrorJustReturn: ""),
                        backO: back,
                        nextO: nextSelected.asDriverOnErrorJustComplete())
        
    }
    
    private func callBackPantau(provider: String, user: Observable<UserResponse>) -> Driver<Void> {
        let instanceId: String? = UserDefaults.Account.get(forKey: .instanceId)
        return NetworkService.instance
            .requestObject(PantauAuthAPI.callback(code: "",
                                                  provider: provider),
                           c: PantauAuthResponse.self)
            .do(onSuccess: { (response) in
                KeychainService.remove(type: NetworkKeychainKind.token)
                KeychainService.remove(type: NetworkKeychainKind.refreshToken)
                AppState.save(response)
            })
            .asObservable()
            .mapToVoid()
            .flatMapLatest({ (_) -> Observable<Void> in
                return NetworkService.instance
                    .requestObject(PantauAuthAPI.firebaseKeys(deviceToken: instanceId ?? "", type: "ios"), c: BaseResponse<InfoFirebaseResponse>.self)
                    .map({ $0.data })
                    .do(onSuccess: { (response) in
                        print("Firebase Key: \(response.firebaseKey)")
                    }, onError: { (error) in
                        print(error.localizedDescription)
                    })
                    .asObservable()
                    .mapToVoid()
            })
            .flatMapLatest({ self.navigator.launchCoordinator(user: user)})
            .asDriverOnErrorJustComplete()
    }
}
