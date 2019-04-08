//
//  RekapViewModel.swift
//  PantauBersama
//
//  Created by asharijuang on 13/02/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Networking
import Common

final class RekapViewModel: ViewModelType {
    
    var input: Input
    var output: Output!
    
    
    struct Input {
        let refreshTrigger: AnyObserver<String>
    }
    
    struct Output {
        let itemsO: Driver<[SimpleSummary]>
        let contributionsO: Driver<ContributionResponse>
        let summaryPresidentO: Driver<SummaryPresidentResponse>
    }
    
    let navigator: RekapNavigator
    
    let errorTracker = ErrorTracker()
    let activityIndicator = ActivityIndicator()
    let headerViewModel = BannerHeaderViewModel()
    
    private let refreshSubject = PublishSubject<String>()
    var itemsProvince = BehaviorRelay<[SummaryPercentage]>(value: [])
    
    
    init(navigator: RekapNavigator) {
        self.navigator = navigator
    
        input = Input(
            refreshTrigger: refreshSubject.asObserver()
        )
        
        /// GET Contributions response
        let contributions = refreshSubject.startWith("")
            .flatMapLatest { (_) -> Observable<ContributionResponse> in
                return NetworkService.instance
                    .requestObject(HitungAPI.getContribution, c: BaseResponse<ContributionResponse>.self)
                    .map({ $0.data })
                    .trackError(self.errorTracker)
                    .trackActivity(self.activityIndicator)
                    .asObservable()
        }
        
        /// GET Calculcations National for Presidents
        let summaryAll = refreshSubject.startWith("")
            .flatMapLatest { (_) -> Observable<SummaryPresidentResponse> in
                return NetworkService.instance
                    .requestObject(HitungAPI.summaryPresidenShow(level: 0,
                                                                 region: 0,
                                                                 tps: 0,
                                                                 realCountId: ""),
                                   c: BaseResponse<SummaryPresidentResponse>.self)
                    .map({ $0.data })
                    .trackError(self.errorTracker)
                    .trackActivity(self.activityIndicator)
                    .asObservable()
        }
        /// GET Summary each province
        let provinceAll = refreshSubject.startWith("")
            .flatMapLatest { [weak self] (_) -> Observable<[SimpleSummary]> in
                guard let `self` = self else { return Observable.empty() }
                return NetworkService.instance
                    .requestObject(HitungAPI.summaryPresidenList(level: 0, region: 0),
                                   c: BaseResponse<SummaryProvinceResponse>.self)
                    .map({ $0.data.percentages })
                    .do(onSuccess: { (response) in
                        print(response)
                    }, onError: { (e) in
                        print(e.localizedDescription)
                    })
                    .trackError(self.errorTracker)
                    .trackActivity(self.activityIndicator)
                    .asObservable()
        }
        
        
        output = Output(itemsO: provinceAll.asDriverOnErrorJustComplete(),
                        contributionsO: contributions.asDriverOnErrorJustComplete(),
                        summaryPresidentO: summaryAll.asDriverOnErrorJustComplete())
    }
}
