//
//  ILiniWordstadiumViewModel.swift
//  PantauBersama
//
//  Created by wisnu bhakti on 22/02/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import Networking
import Common

protocol ILiniWordstadiumViewModelInput {
    var refreshI: AnyObserver<Void> { get }
    var moreI: AnyObserver<Challenge> { get }
    var moreMenuI: AnyObserver<WordstadiumType> { get }
    var seeMoreI: AnyObserver<SectionWordstadium> { get }
    var itemSelectedI: AnyObserver<IndexPath> { get }
    var collectionSelectedI: AnyObserver<Challenge> { get }
}

protocol ILiniWordstadiumViewModelOutput {
    var bannerO: Driver<BannerInfo>! { get }
    var itemSelectedO: Driver<Void>! { get }
    var showHeaderO: Driver<Bool>! { get }
    var itemsO: Driver<[SectionWordstadium]>! { get }
    var moreSelectedO: Driver<Challenge>! { get }
    var moreMenuSelectedO: Driver<String>! { get }
    var isLoading: Driver<Bool>! { get }
    var error: Driver<Error>! { get }
}

protocol ILiniWordstadiumViewModel {
    var input: ILiniWordstadiumViewModelInput { get }
    var output: ILiniWordstadiumViewModelOutput { get }
    
    var errorTracker: ErrorTracker { get }
    var activityIndicator: ActivityIndicator { get }
    var headerViewModel: BannerHeaderViewModel { get }

    func transformToSection(data: GetChallengeResponse,progress: ProgressType, type: LiniType) -> [SectionWordstadium]
    
}

extension ILiniWordstadiumViewModel {
    
    func getChallenge(progress: ProgressType, type: LiniType) -> Observable<GetChallengeResponse>{
        return NetworkService.instance
            .requestObject(WordstadiumAPI.getChallenges(progress: progress, type: type, page: 1, perPage: 4),
                           c: BaseResponse<GetChallengeResponse>.self)
            .map{( $0.data )}
            .trackError(errorTracker)
            .trackActivity(activityIndicator)
            .asObservable()
    }
    
    func transformToSection(data: GetChallengeResponse,progress: ProgressType, type: LiniType) -> [SectionWordstadium] {
        var items:[CellModel] = []
        var title: String = ""
        var description: String = ""
        let challenges = Array(data.challenges.prefix(3))
        let seeMore = data.challenges.count > 3
        
        switch progress {
        case .liveNow:
            items = [CellModel.live(challenges)]
            title = "Live Now"
        case .inProgress:
            items = [CellModel.live(challenges)]
            title = "Challenge in Progress"
        case .comingSoon:
            if challenges.count == 0 {
                items = [CellModel.empty]
            } else {
                for item in challenges {
                    items.append(CellModel.standard(item))
                }
            }
            if type == .public {
                title = "LINIMASA DEBAT"
                description = "Daftar challenge dan debat yang akan atau sudah berlangsung ditampilkan semua di sini."
            } else {
                title = "MY WORDSTADIUM"
                description = "Daftar tantangan dan debat yang akan atau sudah kamu ikuti ditampilkan semua di sini."
            }
        case .done:
            if challenges.count == 0 {
                items = [CellModel.empty]
            } else {
                for item in challenges {
                    items.append(CellModel.standard(item))
                }
            }
            if type == .public {
                title = "Debat: Done"
            } else {
                title = "My Debat: Done"
            }
            
        case .challenge:
            if challenges.count == 0 {
                items = [CellModel.empty]
            } else {
                for item in challenges {
                    items.append(CellModel.standard(item))
                }
            }
            if type == .public {
                title = "Challenge"
            } else {
                title = "My Challenge"
            }
        }
        
        return [SectionWordstadium(title: title, descriptiom: description,type: type, itemType: progress, items: items, seeMore: seeMore )]
    }

}
