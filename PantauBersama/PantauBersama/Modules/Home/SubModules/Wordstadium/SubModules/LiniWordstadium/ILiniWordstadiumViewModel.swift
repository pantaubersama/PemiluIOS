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
    var moreI: AnyObserver<Wordstadium> { get }
    var moreMenuI: AnyObserver<WordstadiumType> { get }
    var seeMoreI: AnyObserver<SectionWordstadium> { get }
    var itemSelectedI: AnyObserver<Wordstadium> { get }
}

protocol ILiniWordstadiumViewModelOutput {
    var bannerO: Driver<BannerInfo>! { get }
    var itemSelectedO: Driver<Void>! { get }
    var showHeaderO: Driver<Bool>! { get }
    var itemsO: Driver<[SectionChallenge]>! { get }
    var moreSelectedO: Driver<Wordstadium>! { get }
    var moreMenuSelectedO: Driver<String>! { get }
    var isLoading: Driver<Bool>! { get }
    var error: Driver<Error>! { get }
    var items: Driver<[Challenge]>! { get }
}

protocol ILiniWordstadiumViewModel {
    var input: ILiniWordstadiumViewModelInput { get }
    var output: ILiniWordstadiumViewModelOutput { get }
    
    var errorTracker: ErrorTracker { get }
    var activityIndicator: ActivityIndicator { get }
    var headerViewModel: BannerHeaderViewModel { get }

    func transformToSection(challenge: [Challenge],progress: ProgressType) -> [SectionChallenge]
    
}

extension ILiniWordstadiumViewModel {
    
    func transformToSection(challenge: [Challenge],progress: ProgressType) -> [SectionChallenge] {
        var item:[Challenge] = []
        var itemLive:[Challenge] = []
        
        switch progress {
        case .liveNow:
            itemLive = challenge
        default:
            item = challenge
        }
        
        return [SectionChallenge(itemType: .challenge, items: item, itemsLive: itemLive )]
    }

}
