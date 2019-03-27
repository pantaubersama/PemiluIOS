//
//  WordstadiumListViewModel.swift
//  PantauBersama
//
//  Created by wisnu bhakti on 15/02/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import Foundation
import Common
import RxSwift
import RxCocoa
import Networking

class WordstadiumListViewModel: ViewModelType {
    var input: Input!
    var output: Output!
    
    struct Input {
        let backTriggger: AnyObserver<Void>
        let refreshTrigger: AnyObserver<Void>
        let nextTrigger: AnyObserver<Void>
        let itemSelectedTrigger: AnyObserver<IndexPath>
        let moreTrigger: AnyObserver<Challenge>
        let moreMenuTrigger: AnyObserver<WordstadiumType>
    }
    
    struct Output {
        let items: Driver<[SectionWordstadium]>
        let isLoading: Driver<Bool>
        let error: Driver<Error>
        let itemSelected: Driver<Void>
        let moreSelectedO: Driver<Challenge>
        let moreMenuSelectedO: Driver<String>
    }
    
    private var navigator: WordstadiumListNavigator
    private let backSubject = PublishSubject<Void>()
    private let refreshSubject = PublishSubject<Void>()
    private let itemSelectedSubject = PublishSubject<IndexPath>()
    private let moreSubject = PublishSubject<Challenge>()
    private let moreMenuSubject = PublishSubject<WordstadiumType>()
    private let nextSubject = PublishSubject<Void>()
    
    let errorTracker = ErrorTracker()
    let activityIndicator = ActivityIndicator()
    
    init(navigator: WordstadiumListNavigator, progress: ProgressType, liniType: LiniType) {
        self.navigator = navigator
        self.navigator.finish = backSubject
        
        input = Input(backTriggger: backSubject.asObserver(),
                      refreshTrigger: refreshSubject.asObserver(),
                      nextTrigger: nextSubject.asObserver(),
                      itemSelectedTrigger: itemSelectedSubject.asObserver(),
                      moreTrigger: moreSubject.asObserver(),
                      moreMenuTrigger: moreMenuSubject.asObserver())
        
        let showItems = refreshSubject.startWith(())
            .flatMapLatest { [unowned self] (_) -> Observable<[SectionWordstadium]> in
                return self.paginateItems(nextBatchTrigger: self.nextSubject.asObservable(), progress: progress, type: liniType)
                    .map{( self.transformToSection(challenge: $0, progress: progress, type: liniType) )}
                    .trackError(self.errorTracker)
                    .trackActivity(self.activityIndicator)
                    .catchErrorJustReturn([])
            }
            .asDriver(onErrorJustReturn: [])
        
        let itemSelected = itemSelectedSubject
            .withLatestFrom(showItems) { (indexPath, challenges) -> CellModel in
                return challenges[indexPath.section].items[indexPath.row]
            }
            .flatMapLatest({ (item) -> Observable<Void> in
                switch item {
                case .standard(let challenge):
                    return navigator.openChallenge(challenge: challenge)
                default :
                    return Observable.empty()
                }

            })
            .asDriverOnErrorJustComplete()
        
        let moreSelectedO = moreSubject
            .asObservable()
            .asDriverOnErrorJustComplete()
        
        let moreMenuSelectedO = moreMenuSubject
            .flatMapLatest { (type) -> Observable<String> in
                switch type {
                case .bagikan:
                    return Observable.just("Tautan telah dibagikan")
                case .salin:
                    return Observable.just("Tautan telah tersalin")
                case .hapus:
                    return Observable.just("Challenge berhasil di hapus")
                }
            }
            .asDriverOnErrorJustComplete()
        
        output = Output(items: showItems,
                        isLoading: activityIndicator.asDriver(),
                        error: errorTracker.asDriver(),
                        itemSelected: itemSelected,
                        moreSelectedO: moreSelectedO,
                        moreMenuSelectedO: moreMenuSelectedO)
    }
    
    func transformToSection(challenge: [Challenge],progress: ProgressType, type: LiniType) -> [SectionWordstadium] {
        var items:[CellModel] = []
        var title: String = ""
        var description: String = ""
        
        for item in challenge {
            items.append(CellModel.standard(item))
        }

        switch progress {
        case .liveNow:
            title = "Live Now"
            description = "Ini daftar debat yang sedang berlangsung. Yuk, pantau bersama!"
        case .inProgress:
            title = "Challenge in Progress"
            description = "Daftar tantangan yang perlu respon dan perlu konfirmasi ditampilkan semua disini. Jangan sampai terlewatkan, yaa."
        case .comingSoon:
            if type == .public {
                title = "Debat: Coming Soon"
            } else {
                title = "My Debat: Coming Soon"
            }
            description = "Jangan lewatkan daftar debat yang akan segera berlangsung. Catat jadwalnya, yaa."
        case .done:
            if type == .public {
                title = "Debat: Done"
            } else {
                title = "My Debat: Done"
            }
            description = "Berikan komentar dan appresiasi pada debat-debat yang sudah selesai. Daftarnya ada di bawah ini:"
        case .challenge:
            if type == .public {
                title = "Challenge"
                description = "Daftar Open Challenge yang bisa diikuti. Pilih debat mana yang kamu ingin ambil tantangannya. Be truthful and gentle!"
            } else {
                title = "My Challenge"
                description = "Daftar tantangan yang perlu respon dan perlu konfirmasi ditampilkan semua disini. Jangan sampai terlewatkan, yaa."
            }
        }
        
        return [SectionWordstadium(title: title, descriptiom: description,type: type, itemType: progress, items: items, seeMore: false )]
    }
    
    private func paginateItems(
        batch: Batch = Batch.initial,
        nextBatchTrigger: Observable<Void>,
        progress: ProgressType,
        type: LiniType) -> Observable<[Challenge]> {
        return recursivelyPaginateItems(batch: batch, nextBatchTrigger: nextBatchTrigger, progress: progress, type: type)
            .scan([], accumulator: { (accumulator, page) in
                return accumulator + page.item
            })
    }
    
    private func recursivelyPaginateItems(
        batch: Batch,
        nextBatchTrigger: Observable<Void>,
        progress: ProgressType,
        type: LiniType) -> Observable<Page<[Challenge]>> {
            return NetworkService.instance
                .requestObject(WordstadiumAPI.getChallenges(progress: progress, type: type, page: batch.page, perPage: batch.limit),
                               c: BaseResponse<GetChallengeResponse>.self)
                .map{( self.transformToPage(response: $0, batch: batch) )}
                .asObservable()
                .paginate(nextPageTrigger: nextBatchTrigger, hasNextPage: { (result) -> Bool in
                    return result.batch.next().hasNextPage
                }, nextPageFactory: { (result) -> Observable<Page<[Challenge]>> in
                    self.recursivelyPaginateItems(batch: result.batch.next(), nextBatchTrigger: nextBatchTrigger, progress: progress, type: type)
                })
                .share(replay: 1, scope: .whileConnected)
    }
    
    private func transformToPage(response: BaseResponse<GetChallengeResponse>, batch: Batch) -> Page<[Challenge]> {
        let nextBatch = Batch(offset: batch.offset,
                              limit: response.data.meta.pages.perPage ?? 10,
                              total: response.data.meta.pages.total,
                              count: response.data.meta.pages.page,
                              page: response.data.meta.pages.page)
        return Page<[Challenge]>(
            item: response.data.challenges,
            batch: nextBatch
        )
    }
}
