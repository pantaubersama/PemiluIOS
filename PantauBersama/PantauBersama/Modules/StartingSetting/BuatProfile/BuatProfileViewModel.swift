//
//  BuatProfileViewModel.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 03/01/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import RxSwift
import RxCocoa
import Networking
import Common

final class BuatProfileViewModel: ViewModelType {
    
    var input: Input
    var output: Output!
    
    struct Input {
        let fullNameI: AnyObserver<String>
        let usernameI: AnyObserver<String>
        let decsI: AnyObserver<String>
        let locationI: AnyObserver<String>
        let educationI: AnyObserver<String>
        let occupationI: AnyObserver<String>
        let avatarI: AnyObserver<UIImage?>
        let viewWillAppearI: AnyObserver<Void>
        let doneI: AnyObserver<Void>
    }
    
    struct Output {
        let done: Driver<Void>
        let userDataO: Driver<UserResponse>
        let avatarO: Driver<Void>
    }
    
    private let avatarS = PublishSubject<UIImage?>()
    private let fullNameS = PublishSubject<String>()
    private let usernameS = PublishSubject<String>()
    private let descS = PublishSubject<String>()
    private let locationS = PublishSubject<String>()
    private let educationS = PublishSubject<String>()
    private let occupationS = PublishSubject<String>()
    private var navigator: BuatProfileCoordinator
    private let doneS = PublishSubject<Void>()
    private let viewWillAppearS = PublishSubject<Void>()
    
    init(navigator: BuatProfileCoordinator) {
        self.navigator = navigator
        
        
        input = Input(
            fullNameI: fullNameS.asObserver(),
            usernameI: usernameS.asObserver(),
            decsI: descS.asObserver(),
            locationI: locationS.asObserver(),
            educationI: educationS.asObserver(),
            occupationI: occupationS.asObserver(),
            avatarI: avatarS.asObserver(),
            viewWillAppearI: viewWillAppearS.asObserver(),
            doneI: doneS.asObserver()
        )
        
        let errorTracker = ErrorTracker()
        let activityIndicator = ActivityIndicator()
        
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
        
        let userData = viewWillAppearS
            .flatMapLatest({ Observable.merge(local, cloud) })
        
        // MARK
        // Avatar selected
        let avatarSelected = avatarS
            .flatMapLatest { (avatar) -> Driver<UserResponse> in
                return NetworkService.instance
                    .requestObject(PantauAuthAPI.meAvatar(avatar: avatar),
                                   c: BaseResponse<UserResponse>.self)
                    .map({ $0.data })
                    .asObservable()
                    .asDriverOnErrorJustComplete()
            }
            .do(onNext: { (user) in
                AppState.saveMe(user)
            })
            .trackError(errorTracker)
            .trackActivity(activityIndicator)
            .mapToVoid()
            .asDriverOnErrorJustComplete()
        
        
        let done = doneS
            .withLatestFrom(Observable.combineLatest(
                fullNameS, usernameS, descS,
                locationS, educationS, occupationS))
            .flatMapLatest { [weak self] (f,u,d,l,e,o) -> Observable<Void> in
                guard let `self` = self else { return Observable.empty() }
                return self.save(fullname: f,
                                 username: u,
                                 desc: d,
                                 location: l,
                                 education: e,
                                 occupation: o,
                                 errorTracker: errorTracker,
                                 activityIndicator: activityIndicator)
            }
            .flatMapLatest({ navigator.nextStep() })
            .asDriverOnErrorJustComplete()
        
        
        
        output = Output(done: done,
                        userDataO: userData.asDriverOnErrorJustComplete(),
                        avatarO: avatarSelected)
        
    }
    
    // MARK
    // Put ME
    private func save(fullname: String, username: String, desc: String,
                      location: String, education: String, occupation: String,
                      errorTracker: ErrorTracker, activityIndicator: ActivityIndicator) -> Observable<Void> {
        return NetworkService.instance
            .requestObject(PantauAuthAPI.putMe(
                parameters: [
                    "fullname": fullname,
                    "username": username,
                    "about": desc,
                    "location": location,
                    "education": education,
                    "occupation": occupation
                ]),
                c: BaseResponse<UserResponse>.self)
            .do(onSuccess: { (response) in
                AppState.saveMe(response.data)
            })
            .trackError(errorTracker)
            .trackActivity(activityIndicator)
            .mapToVoid()
            .catchErrorJustComplete()
        
    }
}
