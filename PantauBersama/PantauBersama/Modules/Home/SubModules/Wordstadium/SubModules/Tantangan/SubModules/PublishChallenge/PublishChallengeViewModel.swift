//
//  PublishChallengeViewModel.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 14/02/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import RxSwift
import RxCocoa
import Networking
import TwitterKit

class PublishChallengeViewModel: ViewModelType {
    
    var input: Input
    var output: Output!
    
    struct Input {
        let backI: AnyObserver<Void>
        let twitterI: AnyObserver<Bool>
        let facebookI: AnyObserver<Bool>
        let twitterLoginI: AnyObserver<Void>
    }
    
    struct Output {
        let meO: Driver<User>
        let twitterO: Driver<Bool>
        let facebookO: Driver<Bool>
        let twitterLoginO: Driver<Void>
    }
    
    private let backS = PublishSubject<Void>()
    private let twitterS = PublishSubject<Bool>()
    private let facebookS = PublishSubject<Bool>()
    private let twitterLoginS = PublishSubject<Void>()
    
    private let errorTracker = ErrorTracker()
    private let activityIndicator = ActivityIndicator()
    private var navigator: PublishChallengeNavigator
    private var type: Bool
    private var user: User
    
    init(navigator: PublishChallengeNavigator, type: Bool, user: User) {
        self.navigator = navigator
        self.navigator.finish = backS
        self.type = type
        self.user = user
        
        input = Input(backI: backS.asObserver(),
                      twitterI: twitterS.asObserver(),
                      facebookI: facebookS.asObserver(),
                      twitterLoginI: twitterLoginS.asObserver())
        
        
        let twitter = twitterLoginS
            .flatMapLatest { (_) -> Observable<Void> in
                return TWTRTwitter.sharedInstance().loginTwitter()
                    .flatMapLatest({ (session) -> Observable<Void> in
                        UserDefaults.Account.set("Connected as \(session.userName)", forKey: .usernameTwitter)
                        UserDefaults.Account.set(session.userID, forKey: .userIdTwitter)
                        return NetworkService.instance
                            .requestObject(PantauAuthAPI.accountsConnect(type: "twitter", oauthToken: session.authToken, oauthSecret: session.authTokenSecret), c: BaseResponse<AccountResponse>.self)
                            .trackError(self.errorTracker)
                            .trackActivity(self.activityIndicator)
                            .catchErrorJustComplete()
                            .mapToVoid()
                    })
            }
            .asDriverOnErrorJustComplete()
        
        
        output = Output(meO: Driver.just(user),
                        twitterO: twitterS.asDriverOnErrorJustComplete(),
                        facebookO: facebookS.asDriverOnErrorJustComplete(),
                        twitterLoginO: twitter)
        
    }
    
}
