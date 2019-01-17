//
//  PenpolViewModel.swift
//  PantauBersama
//
//  Created by Rahardyan Bisma on 21/12/18.
//  Copyright © 2018 PantauBersama. All rights reserved.
//

import Foundation
import Common
import RxSwift
import RxCocoa
import Networking

class PenpolViewModel: ViewModelType {
    var input: Input
    var output: Output!
    
    struct Input {
        let searchTrigger: AnyObserver<Void>
        let addTrigger: AnyObserver<Void>
        let filterTrigger: AnyObserver<(type: FilterType, filterTrigger: AnyObserver<[PenpolFilterModel.FilterItem]>)>
        let refreshTrigger: AnyObserver<Void>
        let viewWillAppearTrigger: AnyObserver<Void>
        let profileTrigger: AnyObserver<Void>
        let catatanTrigger: AnyObserver<Void>
    }
    
    struct Output {
        let searchSelected: Driver<Void>
        let filterSelected: Driver<Void>
        let addSelected: Driver<Void>
        let userO: Driver<UserResponse>
        let profileSelected: Driver<Void>
        let catatanSelected: Driver<Void>
    }
    
    let navigator: PenpolNavigator
    private let addSubject = PublishSubject<Void>()
    private let filterSubject = PublishSubject<(type: FilterType, filterTrigger: AnyObserver<[PenpolFilterModel.FilterItem]>)>()
    private let refreshSubject = PublishSubject<Void>()
    private let searchSubject = PublishSubject<Void>()
    private let viewWillAppearSubject = PublishSubject<Void>()
    private let activityIndicator = ActivityIndicator()
    private let errorTracker = ErrorTracker()
    private let profileSubject = PublishSubject<Void>()
    private let catatanSubject = PublishSubject<Void>()
    
    init(navigator: PenpolNavigator) {
        self.navigator = navigator
        
        input = Input(searchTrigger: searchSubject.asObserver(),
                      addTrigger: addSubject.asObserver(),
                      filterTrigger: filterSubject.asObserver(),
                      refreshTrigger: refreshSubject.asObserver(),
                      viewWillAppearTrigger: viewWillAppearSubject.asObserver(),
                      profileTrigger: profileSubject.asObserver(),
                      catatanTrigger: catatanSubject.asObserver())
        
        let add = addSubject
            .flatMap({navigator.launchCreateAsk(loadCreatedTrigger: self.refreshSubject.asObserver())})
            .asDriver(onErrorJustReturn: ())
        
        let filter = filterSubject
            .flatMap({ navigator.launchFilter(filterType: $0.type, filterTrigger: $0.filterTrigger) })
            .asDriver(onErrorJustReturn: ())
        
        let search = searchSubject
            .flatMapLatest({ navigator.launchSearch() })
            .asDriver(onErrorJustReturn: ())
        
        let profile = profileSubject
            .flatMapLatest({ navigator.launchProfile() })
            .asDriver(onErrorJustReturn: ())
        
        let note = catatanSubject
            .flatMapLatest({ navigator.launchNote() })
            .asDriver(onErrorJustReturn: ())
        
        // MARK
        // Get local user response
        let cloud = NetworkService.instance.requestObject(
            PantauAuthAPI.me,
            c: BaseResponse<UserResponse>.self)
            .map({ $0.data })
            .do(onSuccess: { (response) in
                AppState.saveMe(response)
            })
            .trackError(errorTracker)
            .trackActivity(activityIndicator)
            .asObservable()
            .catchErrorJustComplete()
        
        let local: Observable<UserResponse> = AppState.local(key: .me)
        let userData = viewWillAppearSubject
            .flatMapLatest({ Observable.merge(cloud, local) })
            .asDriverOnErrorJustComplete()
        
        output = Output(searchSelected: search,
                        filterSelected: filter,
                        addSelected: add,
                        userO: userData,
                        profileSelected: profile,
                        catatanSelected: note)
    }
}
