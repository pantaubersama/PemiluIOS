//
//  RekapListViewModel.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 08/04/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Networking

final class RekapListViewModel: ViewModelType {
    
    var input: Input
    var output: Output!
    
    struct Input {
        let refreshI: AnyObserver<String>
        let backI: AnyObserver<Void>
        let itemSelectedI: AnyObserver<IndexPath>
    }
    
    struct Output {
        let itemsO: Driver<[SimpleSummary]>
        let nameRegionO: Driver<String>
        let backO: Driver<Void>
        let itemSelectedO: Driver<Void>
    }
    
    private let navigator: RekapListNavigator
    private let region: Region
    
    private let refreshS = PublishSubject<String>()
    private let backS = PublishSubject<Void>()
    private let itemSelectedS = PublishSubject<IndexPath>()
    private let errorTracker = ErrorTracker()
    private let activityIndicator = ActivityIndicator()
    
    init(navigator: RekapListNavigator, region: Region) {
        self.navigator = navigator
        self.region = region
        
        input = Input(refreshI: refreshS.asObserver(),
                      backI: backS.asObserver(),
                      itemSelectedI: itemSelectedS.asObserver())
        
        let back = backS
            .flatMapLatest({ navigator.back() })
            .asDriverOnErrorJustComplete()
        
        /// TODO: This response fine until level 3
        /// if level 3 we need change into village response
        let items = refreshS.startWith("")
            .flatMapLatest { [weak self] (_) ->
                Observable<[SimpleSummary]> in
                guard let `self` = self else { return Observable.empty() }
                return NetworkService.instance
                    .requestObject(HitungAPI.summaryPresidenList(level: region.level, region: region.id),
                                   c: BaseResponse<SummaryProvinceResponse>.self)
                    .map({ $0.data.percentages })
                    .do(onSuccess: { (response) in
                        
                    }, onError: { (e) in
                        print(e.localizedDescription)
                    })
                    .trackError(self.errorTracker)
                    .trackActivity(self.activityIndicator)
                    .asObservable()
            }
        
        let itemSelected = itemSelectedS
            .withLatestFrom(items) { indexPath, model in
                return model[indexPath.row]
            }
            .flatMapLatest { (summary) -> Observable<Void> in
                if summary.region.level < 3 {
                    return navigator.launchDetail(item: summary.region)
                } else {
                    // navigate to village
                    return navigator.launchDetailVillage(data: summary.region.id)
                }
            }
            .asDriverOnErrorJustComplete()
        
        
        let regionName = Observable.just(self.region.name)
            .asDriverOnErrorJustComplete()
        
        output = Output(itemsO: items.asDriverOnErrorJustComplete(),
                        nameRegionO: regionName, backO: back,
                        itemSelectedO: itemSelected)
        
    }
    
}
