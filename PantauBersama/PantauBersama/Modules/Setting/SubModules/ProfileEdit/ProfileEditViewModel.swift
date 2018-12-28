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
    }
    
    
    struct Output {
        let items: Driver<[SectionOfProfileInfoData]>
    }
    
    private var navigator: ProfileEditNavigator
    private let backS = PublishSubject<Void>()
    private let doneS = PublishSubject<Void>()
    private let viewWillAppearS = PublishSubject<Void>()
    private let data: User
    
    init(navigator: ProfileEditNavigator, data: User) {
        self.navigator = navigator
        self.navigator.finish = backS
        self.data = data
        // MARK: Input
        input = Input(backI: backS.asObserver(),
                      doneI: doneS.asObserver(),
                      viewWillAppearI: viewWillAppearS.asObserver())
        
        
        // MARK:
        // Observable user
        // map to Section Of Profile Info Data
        let items: Observable<[SectionOfProfileInfoData]> = viewWillAppearS
            .map({ data })
            .flatMapLatest { (data) -> Observable<[SectionOfProfileInfoData]> in
                return ProfileInfoDummyData.profileInfoData(data: data)
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
        
        // MARK: Output
        output = Output(items: showItems.asDriverOnErrorJustComplete())
    }
    
}
