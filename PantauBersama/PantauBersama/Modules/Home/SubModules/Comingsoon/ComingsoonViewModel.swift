//
//  ComingsoonViewModel.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 21/01/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import RxSwift
import RxCocoa
import Common
import Networking

final class ComingsoonViewModel: ViewModelType {
    
    let input: Input
    let output: Output!
    
    struct Input {
        let profileI: AnyObserver<Void>
        let searchI: AnyObserver<Void>
        let noteI: AnyObserver<Void>
        let notifI: AnyObserver<Void>
        let pantauI: AnyObserver<Void>
        let facebookI: AnyObserver<Void>
        let instagramI: AnyObserver<Void>
        let twitterI: AnyObserver<Void>
        let viewWillAppearI: AnyObserver<Void>
    }
    
    struct Output {
        let profileO: Driver<Void>
        let searchO: Driver<Void>
        let noteO: Driver<Void>
        let notifO: Driver<Void>
        let pantauO: Driver<Void>
        let facebookO: Driver<Void>
        let instagramO: Driver<Void>
        let twitterO: Driver<Void>
        let userDataO: Driver<UserResponse>
    }

    private let profileS = PublishSubject<Void>()
    private let searchS = PublishSubject<Void>()
    private let noteS = PublishSubject<Void>()
    private let notifS = PublishSubject<Void>()
    private let pantauS = PublishSubject<Void>()
    private let facebookS = PublishSubject<Void>()
    private let instagramS = PublishSubject<Void>()
    private let twitterS = PublishSubject<Void>()
    private let viewWillAppearS = PublishSubject<Void>()
    private var navigator: ComingsoonNavigator
    private let activityIndicator = ActivityIndicator()
    private let errorTracker = ErrorTracker()
    
    init(navigator: ComingsoonNavigator) {
        self.navigator = navigator
        
        
        input = Input(
            profileI: profileS.asObserver(),
            searchI: searchS.asObserver(),
            noteI: noteS.asObserver(),
            notifI: notifS.asObserver(),
            pantauI: pantauS.asObserver(),
            facebookI: facebookS.asObserver(),
            instagramI: instagramS.asObserver(),
            twitterI: twitterS.asObserver(),
            viewWillAppearI: viewWillAppearS.asObserver()
        )
        
        let local: Observable<UserResponse> = AppState.local(key: .me)
        let cloud = NetworkService.instance.requestObject(
            PantauAuthAPI.me,
            c: BaseResponse<UserResponse>.self)
            .map({ $0.data })
            .do(onSuccess: { (response) in
                AppState.saveMe(response)
            }, onError: { (e) in
                print(e.localizedDescription)
            })
            .trackError(errorTracker)
            .trackActivity(activityIndicator)
            .asObservable()
            .catchErrorJustComplete()
        
        let userData = viewWillAppearS
            .flatMapLatest({ Observable.merge(local, cloud)})
        
        let profile = profileS
            .flatMapLatest{( navigator.launchProfile(isMyAccount: true, userId: nil) )}
            .asDriverOnErrorJustComplete()
        
        let search = searchS
            .flatMapLatest({ navigator.launchSearch() })
            .asDriverOnErrorJustComplete()
        
        let note = noteS
            .flatMapLatest({ navigator.launchNote() })
            .asDriverOnErrorJustComplete()
        
        let pantau = pantauS
            .flatMapLatest({ navigator.launchWeb(link: "https://pantaubersama.com")})
            .asDriverOnErrorJustComplete()
        
        let facebook = facebookS
            .flatMapLatest({ navigator.launchWeb(link: "https://www.facebook.com/pantaubersama/")})
            .asDriverOnErrorJustComplete()
        
        let instagram = instagramS
            .flatMapLatest({ navigator.launchWeb(link: "https://www.instagram.com/pantaubersama/")})
            .asDriverOnErrorJustComplete()
        
        let twitter = twitterS
            .flatMapLatest({ navigator.launchWeb(link: "https://twitter.com/pantaubersama")})
            .asDriverOnErrorJustComplete()
        
        
        output = Output(
            profileO: profile,
            searchO: search,
            noteO: note,
            notifO: notifS.asDriverOnErrorJustComplete(),
            pantauO: pantau,
            facebookO: facebook,
            instagramO: instagram,
            twitterO: twitter,
            userDataO: userData.asDriverOnErrorJustComplete()
        )
    }
    
    
}
