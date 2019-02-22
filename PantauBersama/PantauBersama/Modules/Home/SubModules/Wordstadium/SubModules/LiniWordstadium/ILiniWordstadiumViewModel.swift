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
    var refreshI: AnyObserver<String> { get }
    var moreI: AnyObserver<Wordstadium> { get }
    var moreMenuI: AnyObserver<WordstadiumType> { get }
    var seeMoreI: AnyObserver<SectionWordstadium> { get }
    var itemSelectedI: AnyObserver<Wordstadium> { get }
}

protocol ILiniWordstadiumViewModelOutput {
    var bannerO: Driver<BannerInfo>! { get }
    var itemSelectedO: Driver<Void>! { get }
    var showHeaderO: Driver<Bool>! { get }
    var itemsO: Driver<[SectionWordstadium]>! { get }
    var moreSelectedO: Driver<Wordstadium>! { get }
    var moreMenuSelectedO: Driver<String>! { get }
}

protocol ILiniWordstadiumViewModel {
    var input: ILiniWordstadiumViewModelInput { get }
    var output: ILiniWordstadiumViewModelOutput { get }
    
    var errorTracker: ErrorTracker { get }
    var activityIndicator: ActivityIndicator { get }
    var headerViewModel: BannerHeaderViewModel { get }
    
}

extension ILiniWordstadiumViewModel {
    
}
