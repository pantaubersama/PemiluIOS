//
//  ShareBadgeViewModel.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 07/01/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import RxSwift
import RxCocoa
import Networking
import Common

final class ShareBadgeViewModel: ViewModelType {
    
    var input: Input
    var output: Output!
    
    struct Input {
        let backI: AnyObserver<Void>
        let viewWillAppearI: AnyObserver<Void>
        let shareI: AnyObserver<Void>
    }
    
    struct Output {
        let dataO: Driver<AchievedSingleResponse>
        let shareO: Driver<Void>
    }
    
    private var navigator: ShareBadgeNavigator
    private let backS = PublishSubject<Void>()
    private let activityIndicator = ActivityIndicator()
    private let errorTracker = ErrorTracker()
    private let viewWillAppearS = PublishSubject<Void>()
    private let shareS = PublishSubject<Void>()
    
    init(navigator: ShareBadgeNavigator, id: String) {
        self.navigator = navigator
        self.navigator.finish = backS
        
        input = Input(backI: backS.asObserver(),
                      viewWillAppearI: viewWillAppearS.asObserver(),
                      shareI: shareS.asObserver())
        
        // MARK
        // Get data from cloud
        let data = NetworkService.instance
            .requestObject(PantauAuthAPI.achievedBadges(id: id),
                           c: BaseResponse<AchievedSingleResponse>.self)
            .map({ $0.data })
            .asObservable()
            .trackError(errorTracker)
            .trackActivity(activityIndicator)
            .catchErrorJustComplete()
        
        let badgeData = viewWillAppearS
            .flatMapLatest({ data })
            
        let share = shareS
            .flatMapLatest({ navigator.shareBadge(id: id) })
        
        
        output = Output(dataO: badgeData.asDriverOnErrorJustComplete(),
                        shareO: share.asDriverOnErrorJustComplete())
        
    }
    
}
