//
//  InfoNotifViewModel.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 01/02/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import RxSwift
import Networking
import Common
import RxCocoa

final class InfoNotifViewModel: ViewModelType {
    
    var input: Input
    var output: Output!
    
    struct Input {
        let refreshI: AnyObserver<Void>
        let itemSelected: AnyObserver<IndexPath>
    }
    
    
    struct Output {
        let items: Driver<[ICellConfigurator]>
    }
    
    private let refreshS = PublishSubject<Void>()
    private let itemSelectedS = PublishSubject<IndexPath>()
    let errorTrackker = ErrorTracker()
    let activityIndicator = ActivityIndicator()
    let navigator: NotificationNavigator
    
    init(navigator: NotificationNavigator) {
        self.navigator = navigator
        
        input = Input(refreshI: refreshS.asObserver(),
                      itemSelected: itemSelectedS.asObserver())
        
        
        let items = refreshS.startWith(())
            .flatMapLatest { [unowned self] (_) -> Observable<[NotificationRecord]> in
                return NetworkService
                    .instance
                    .requestObject(NotificationAPI.recordNotification,
                                   c: BaseResponse<RecordNotificationResponse>.self)
                    .map({ $0.data.notifications })
                    .do(onSuccess: { (response) in
                        print(response)
                    }, onError: { (error) in
                        print(error.localizedDescription)
                    })
                    .trackError(self.errorTrackker)
                    .trackActivity(self.activityIndicator)
            }
        
        let itemCell = items
            .map { (list) -> [ICellConfigurator] in
                return list.map({ (notif) -> ICellConfigurator in
                    return InfoNotifiCellConfigured(item: InfoNotifCell.Input(notif: notif))
                })
            }
        
        output = Output(items: itemCell.asDriver(onErrorJustReturn: []))
        
    }
}
