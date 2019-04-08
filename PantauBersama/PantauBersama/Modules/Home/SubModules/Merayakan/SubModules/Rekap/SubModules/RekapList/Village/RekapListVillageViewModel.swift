//
//  RekapListVillageViewModel.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 08/04/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Networking

final class RekapListVillageViewModel: ViewModelType {

    var input: Input
    var output: Output!

    struct Input {
        let refreshI: AnyObserver<String>
        let backI: AnyObserver<Void>
    }

    struct Output {
        let itemsO: Driver<[SummaryVillage]>
        let backO: Driver<Void>
        let titleO: Driver<String>
    }
    
    private let navigator: RekapListVillageNavigator
    private let data: Int
    private let errorTracker = ErrorTracker()
    private let activityIndicator = ActivityIndicator()
    
    private let backS = PublishSubject<Void>()
    private let refreshS = PublishSubject<String>()
    private let titleRelay = BehaviorRelay<String>(value: "")

    init(navigator: RekapListVillageNavigator, data: Int) {
        self.navigator = navigator
        self.data = data
        
        input = Input(refreshI: refreshS.asObserver(),
                      backI: backS.asObserver())
        
        let back = backS
            .flatMapLatest({ navigator.back() })
            .asDriverOnErrorJustComplete()
        
        let items = refreshS.startWith("")
            .flatMapLatest { [weak self] (_) -> Observable<[SummaryVillage]> in
                guard let `self` = self else { return Observable.empty() }
                return NetworkService.instance
                    .requestObject(HitungAPI.summaryPresidenList(level: 3, region: data),
                                   c: BaseResponse<SummaryVillageeResponse>.self)
                    .do(onSuccess: { (response) in
                        self.titleRelay.accept(response.data.region.name)
                    }, onError: { (e) in
                        print(e.localizedDescription)
                    })
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
            
        
        output = Output(itemsO: items.asDriverOnErrorJustComplete(),
                        backO: back,
                        titleO: self.titleRelay.asDriverOnErrorJustComplete())
        
    }

}
