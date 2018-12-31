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
        let updateTrigger: AnyObserver<Void>
        let nameI: AnyObserver<String>
        let usernameI: AnyObserver<String>
        let addressI: AnyObserver<String>
        let aboutI: AnyObserver<String>
        let educationI: AnyObserver<String>
        let occupationI: AnyObserver<String>
    }
    
    
    struct Output {
        let items: Driver<[SectionOfProfileInfoData]>
        let title: Driver<String>
        let userData: Driver<User>
        let avatarSelected: Driver<Void>
        let done: Driver<Void>
    }
    
    private var navigator: ProfileEditNavigator
    private let backS = PublishSubject<Void>()
    private let doneS = PublishSubject<Void>()
    private let viewWillAppearS = PublishSubject<Void>()
    private let data: User
    private var type: ProfileHeaderItem
    private let avatarS = PublishSubject<UIImage?>()
    private let updateS = PublishSubject<Void>()
    private let nameS = PublishSubject<String>()
    private let usernameS = PublishSubject<String>()
    private let addressS = PublishSubject<String>()
    private let aboutS = PublishSubject<String>()
    private let educationS = PublishSubject<String>()
    private let occupationS = PublishSubject<String>()
    
    private let errorTracker = ErrorTracker()
    private let activityIndicator = ActivityIndicator()
    
    init(navigator: ProfileEditNavigator, data: User, type: ProfileHeaderItem) {
        self.navigator = navigator
        self.navigator.finish = backS
        self.data = data
        self.type = type
        
        
        // MARK: Input
        input = Input(backI: backS.asObserver(),
                      doneI: doneS.asObserver(),
                      viewWillAppearI: viewWillAppearS.asObserver(),
                      avatarI: avatarS.asObserver(),
                      updateTrigger: updateS.asObserver(),
                      nameI: nameS.asObserver(),
                      usernameI: usernameS.asObserver(),
                      addressI: addressS.asObserver(),
                      aboutI: aboutS.asObserver(),
                      educationI: educationS.asObserver(),
                      occupationI: occupationS.asObserver())
        
        
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
        
        // MARK
        // Enable update profile
        let profileUpdate = doneS
            .withLatestFrom(Observable.combineLatest(
                nameS, usernameS, addressS, aboutS,
                educationS, occupationS))
            .flatMapLatest { [weak self] (name, username, address, about,
                education, occupation) -> Observable<Void> in
                guard let `self` = self else { return Observable.empty() }
                return self.updateMe(firstName: name,
                                     lastName: name,
                                     username: username,
                                     about: about,
                                     location: address,
                                     education: education,
                                     occupation: occupation,
                                     errorTracker: self.errorTracker,
                                     activityIndicator: self.activityIndicator)
            .do(onNext: { (_) in
                navigator.back()
            })
        }.asDriverOnErrorJustComplete()
        
        
        // MARK: Output
        output = Output(items: showItems.asDriverOnErrorJustComplete(),
                        title: Driver.just(type.title),
                        userData: userData,
                        avatarSelected: avatarSelected,
                        done: profileUpdate)
    }
    
    
    private func updateMe(firstName: String, lastName: String, username: String,
                          about: String, location: String, education: String, occupation: String, errorTracker: ErrorTracker, activityIndicator: ActivityIndicator) -> Observable<Void> {
        print(firstName)
        return NetworkService.instance
            .requestObject(PantauAuthAPI.putMe(
                parameters: [
                    "first_name": firstName,
                    "last_name": lastName,
                    "username": username,
                    "about": about,
                    "location": location,
                    "education": education,
                    "occupation": occupation
                ]), c: BaseResponse<UserResponse>.self)
            .do(onSuccess: { (reponse) in
                print("SUCCESS:\(reponse)")
            }, onError: { (error) in
                print(error.localizedDescription)
            })
            .trackError(errorTracker)
            .trackActivity(activityIndicator)
            .mapToVoid()
            .catchErrorJustReturn(())
    }
    
}
