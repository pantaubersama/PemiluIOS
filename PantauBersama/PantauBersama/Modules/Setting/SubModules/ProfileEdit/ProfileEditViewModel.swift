//
//  ProfileEditViewModel.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 25/12/18.
//  Copyright © 2018 PantauBersama. All rights reserved.
//

import RxSwift
import RxCocoa
import Common
import Networking

class ProfileEditViewModel: ViewModelType {
    
    var input: Input
    var output: Output!
    
    struct Input {
        let backI: AnyObserver<Void>
        let doneI: AnyObserver<Void>
        let viewWillAppearI: AnyObserver<Void>
        let avatarI: AnyObserver<UIImage?>
    }
    
    
    struct Output {
        let items: Driver<[SectionOfProfileInfoData]>
        let title: Driver<String>
        let userData: Driver<User>
        let avatarSelected: Driver<Void>
    }
    
    private var navigator: ProfileEditNavigator
    private let backS = PublishSubject<Void>()
    private let doneS = PublishSubject<Void>()
    private let viewWillAppearS = PublishSubject<Void>()
    private let data: User
    private var type: ProfileHeaderItem
    private let avatarS = PublishSubject<UIImage?>()
    
    init(navigator: ProfileEditNavigator, data: User, type: ProfileHeaderItem) {
        self.navigator = navigator
        self.navigator.finish = backS
        self.data = data
        self.type = type
        // MARK: Input
        input = Input(backI: backS.asObserver(),
                      doneI: doneS.asObserver(),
                      viewWillAppearI: viewWillAppearS.asObserver(),
                      avatarI: avatarS.asObserver())
        
        
        // MARK:
        // Observable user
        // map to Section Of Profile Info Data
        let items: Observable<[SectionOfProfileInfoData]> = viewWillAppearS
            .map({ data })
            .flatMapLatest { (data) -> Observable<[SectionOfProfileInfoData]> in
                return ProfileInfoDummyData.profileInfoData(data: data, type: type)
            }
            .share()
        
        let showItems = items
            .map { (a) -> [SectionOfProfileInfoData] in
                return a.map({ (b) -> SectionOfProfileInfoData in
                    var temp = b
                    temp.items = b.items
                    return temp
                })
        }
        
        // MARK
        // Get user data
        let userData = viewWillAppearS
            .withLatestFrom(Observable.just(data))
            .asDriverOnErrorJustComplete()
        
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
            }, onError: { (e) in
                print(e.localizedDescription)
            })
            .mapToVoid()
            .asDriverOnErrorJustComplete()
        
        
        // MARK: Output
        output = Output(items: showItems.asDriverOnErrorJustComplete(),
                        title: Driver.just(type.title),
                        userData: userData,
                        avatarSelected: avatarSelected)
    }
    
}
