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
        let shareI: AnyObserver<UIImage?>
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
    private let shareS = PublishSubject<UIImage?>()
    
    private var isFromDeeplink: Bool
    private var userId: String?
    
    init(navigator: ShareTrendNavigator, isFromDeeplink: Bool, userId: String?) {
        self.navigator = navigator
        self.navigator.finish = backS
        self.isFromDeeplink = isFromDeeplink
        self.userId = userId
        
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
        
        let dataDeeplink = NetworkService.instance
            .requestObject(QuizAPI.getTotalQuizParticipationResult(id: userId ?? ""),
                           c: BaseResponse<TrendResponse>.self)
            .map({ $0.data })
            .asObservable()
            .catchErrorJustComplete()
        
        let trendData = viewWillAppearS
            .flatMapLatest({ isFromDeeplink ? dataDeeplink : data })
        
        let share = Observable.combineLatest(shareS, data.asObservable())
            .flatMapLatest { (image,trend) -> Observable<Void> in
                if let image = image {
                    return navigator.shareTrendResult(image: image ,data: trend)
                } else {
                    return Observable.empty()
                }
            }
        
        output = Output(dataO: trendData.asDriverOnErrorJustComplete(),
                        shareO: share.asDriverOnErrorJustComplete())
    }
}
