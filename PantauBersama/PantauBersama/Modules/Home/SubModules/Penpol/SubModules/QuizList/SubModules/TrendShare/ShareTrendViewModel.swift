//
//  ShareTrendViewModel.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 20/01/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import RxSwift
import RxCocoa
import Networking

class ShareTrendViewModel: ViewModelType {
    
    let input: Input
    let output: Output!
    
    struct Input {
        let backI: AnyObserver<Void>
        let viewWillAppearI: AnyObserver<Void>
        let shareI: AnyObserver<Void>
    }
    
    struct Output {
        let dataO: Driver<TrendResponse>
        let shareO: Driver<Void>
    }
    
    private var navigator: ShareTrendNavigator
    private let backS = PublishSubject<Void>()
    private let activityIndicator = ActivityIndicator()
    private let errorTracker = ErrorTracker()
    private let viewWillAppearS = PublishSubject<Void>()
    private let shareS = PublishSubject<Void>()
    
    init(navigator: ShareTrendNavigator) {
        self.navigator = navigator
        self.navigator.finish = backS
        
        input = Input(backI: backS.asObserver(),
                      viewWillAppearI: viewWillAppearS.asObserver(),
                      shareI: shareS.asObserver())
        
        let data = NetworkService.instance
            .requestObject(
                QuizAPI.getTotalResult(),
                c: BaseResponse<TrendResponse>.self
            )
            .map{ ($0.data) }
            .asObservable()
            .catchErrorJustComplete()
        
        let trendData = viewWillAppearS
            .flatMapLatest({ data })
        
        let share = shareS
            .withLatestFrom(data)
            .flatMapLatest { (trend) -> Observable<Void> in
                return navigator.shareTrendResult(data: trend)
            }
        
        output = Output(dataO: trendData.asDriverOnErrorJustComplete(),
                        shareO: share.asDriverOnErrorJustComplete())
    }
}
