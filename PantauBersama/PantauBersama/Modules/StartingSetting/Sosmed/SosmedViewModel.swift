//
//  SosmedViewModel.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 03/01/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import RxSwift
import RxCocoa
import Networking
import TwitterKit
import FBSDKLoginKit
import FBSDKCoreKit

final class SosmedViewModel: ViewModelType {
    
    var input: Input
    var output: Output!
    
    struct Input {
        let backI: AnyObserver<Void>
        let doneI: AnyObserver<Void>
        let itemSelectedI: AnyObserver<IndexPath>
        let viewWillAppearI: AnyObserver<Void>
        let refreshI: AnyObserver<Void>
        let facebookI: AnyObserver<String>
        let facebookGraphI: AnyObserver<Void>
    }
    
    struct Output {
        let itemsO: Driver<[SectionOfSettingData]>
        let doneO: Driver<Void>
        let itemsSelectedO: Driver<Void>
        let loadingO: Driver<Bool>
        let errorO: Driver<Error>
        let facebookO: Driver<Void>
        let facebookMeO: Driver<MeFacebookResponse>
    }
    
    private let backS = PublishSubject<Void>()
    private let doneS = PublishSubject<Void>()
    private let itemSelectedS = PublishSubject<IndexPath>()
    private var navigator: SosmedNavigator
    private let viewWillAppearS = PublishSubject<Void>()
    private let refreshS = PublishSubject<Void>()
    private let facebookS = PublishSubject<String>()
    private let facebookGraphS = PublishSubject<Void>()
    
    init(navigator: SosmedNavigator) {
        self.navigator = navigator
        self.navigator.finish = backS
        
        let errorTracker = ErrorTracker()
        let activityIndicator = ActivityIndicator()
        
        
        input = Input(
            backI: backS.asObserver(),
            doneI: doneS.asObserver(),
            itemSelectedI: itemSelectedS.asObserver(),
            viewWillAppearI: viewWillAppearS.asObserver(),
            refreshI: refreshS.asObserver(),
            facebookI: facebookS.asObserver(),
            facebookGraphI: facebookGraphS.asObserver()
        )
        
        let refresh = refreshS.startWith(())
        
        let items = Observable.just([
            SectionOfSettingData(header: "Twitter", items: [
                SettingData.twitter
                ]),
            SectionOfSettingData(header: "Facebook", items: [
                SettingData.facebook
                ])
            ])
        
        let item = Observable.combineLatest(viewWillAppearS, refresh)
            .withLatestFrom(items)
            .asDriverOnErrorJustComplete()
        
        let done = doneS
            .flatMapLatest({ navigator.launchHome() })
            .asDriverOnErrorJustComplete()
        
        let itemSelected = itemSelectedS
            .withLatestFrom(item) { indexPath, item in
                return item[indexPath.section].items[indexPath.row]
            }
            .flatMapLatest { (type) -> Observable<Void> in
                switch type {
                case .twitter:
                    // Assume user for first time doesn't need twitter state
                    return TWTRTwitter.sharedInstance().loginTwitter()
                        .flatMapLatest({ (session) -> Observable<Void> in
                            UserDefaults.Account.set("Connected as \(session.userName)", forKey: .usernameTwitter)
                            UserDefaults.Account.set(session.userID, forKey: .userIdTwitter)
                            return NetworkService.instance
                                .requestObject(PantauAuthAPI
                                    .accountsConnect(
                                        type: "twitter",
                                        oauthToken: session.authToken,
                                        oauthSecret: session.authTokenSecret),
                                               c: BaseResponse<AccountResponse>.self)
                                .trackError(errorTracker)
                                .trackActivity(activityIndicator)
                                .catchErrorJustComplete()
                                .mapToVoid()
                        })
                        .mapToVoid()
                case .facebook:
                    return Observable.empty()
                default: return Observable.empty()
                }
            }
        
        
        // MARK
        // Facbeook
        let facebook = facebookS
            .flatMapLatest { (result) -> Observable<Void> in
                return NetworkService.instance
                    .requestObject(PantauAuthAPI
                        .accountsConnect(type: "facebook",
                                         oauthToken: result,
                                         oauthSecret: ""),
                                   c: BaseResponse<AccountResponse>.self)
                    .trackError(errorTracker)
                    .trackActivity(activityIndicator)
                    .catchErrorJustComplete()
                    .mapToVoid()
            }.mapToVoid()
        
        let meFacebook = facebookGraphS
            .withLatestFrom(viewWillAppearS)
            .flatMapLatest { (_) -> Observable<MeFacebookResponse> in
                if let request = FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "name, email, gender, birthday, photos"]) {
                    return request.fetchMeFacebook()
                }
                return Observable<MeFacebookResponse>.empty()
        }
        
        output = Output(
            itemsO: item,
            doneO: done,
            itemsSelectedO: itemSelected.asDriverOnErrorJustComplete(),
            loadingO: activityIndicator.asDriver(),
            errorO: errorTracker.asDriver(),
            facebookO: facebook.asDriverOnErrorJustComplete(),
            facebookMeO: meFacebook.asDriverOnErrorJustComplete())
        
    }
    
}
