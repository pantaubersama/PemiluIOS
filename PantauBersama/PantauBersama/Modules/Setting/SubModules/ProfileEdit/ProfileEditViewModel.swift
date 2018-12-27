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

class ProfileEditViewModel: ViewModelType {
    
    var input: Input
    var output: Output!
    
    struct Input {
        let backI: AnyObserver<Void>
        let doneI: AnyObserver<Void>
        let viewWillAppearI: AnyObserver<Void>
    }
    
    
    struct Output {
        let items: Driver<[SectionOfProfileEditData]>
    }
    
    private var navigator: ProfileEditNavigator
    private let backS = PublishSubject<Void>()
    private let doneS = PublishSubject<Void>()
    private let viewWillAppearS = PublishSubject<Void>()
    
    init(navigator: ProfileEditNavigator) {
        self.navigator = navigator
        self.navigator.finish = backS
        // MARK: Input
        input = Input(backI: backS.asObserver(),
                      doneI: doneS.asObserver(),
                      viewWillAppearI: viewWillAppearS.asObserver())
        
        // MARK: Build cell for UITableView
        let items = Driver.just([
            SectionOfProfileEditData(items: [
                SettingProfile.namaLengkap,
                SettingProfile.username,
                SettingProfile.lokasi,
                SettingProfile.deksripsi,
                SettingProfile.pendidikan,
                SettingProfile.pekerjaan
            ])
        ])
        
        // MARK: Output
        output = Output(items: items)
    }
    
}
