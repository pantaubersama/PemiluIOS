//
//  UploadC1ViewModel.swift
//  PantauBersama
//
//  Created by Nanang Rafsanjani on 06/03/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import Foundation
import Common
import RxSwift
import RxCocoa
import Networking
import RxDataSources

class UploadC1ViewModel: ViewModelType {
    struct Input {
        let backI: AnyObserver<Void>
        let addImagesI: AnyObserver<Int>
        let imagesI: AnyObserver<StashImages>
        let simpanI: AnyObserver<Void>
    }
    
    struct Output {
        let backO: Driver<Void>
        let addImageO: Driver<Int>
        let imageUpdatedO: Driver<StashImages>
        let simpanO: Driver<Void>
    }
    
    var input: Input
    var output: Output!
    
    private let navigator: UploadC1Navigator
    private let backS = PublishSubject<Void>()
    
    private let addImagesS = PublishSubject<Int>()
    private let imageS = PublishSubject<StashImages>()
    private let simpanS = PublishSubject<Void>()
    
    
    var presidenImageRelay = BehaviorRelay<[StashImages]>(value: [])
    var dprImageRelay = BehaviorRelay<[StashImages]>(value: [])
    var dpdImageRelay = BehaviorRelay<[StashImages]>(value: [])
    var dprdProvImageRelay = BehaviorRelay<[StashImages]>(value: [])
    var dprdImageRelay = BehaviorRelay<[StashImages]>(value: [])
    var suasanaImageRelay = BehaviorRelay<[StashImages]>(value: [])
    var relayImages = BehaviorRelay<[StashImages]>(value: [])
    
    init(navigator: UploadC1Navigator) {
        self.navigator = navigator
        
        input = Input(backI: backS.asObserver(),
                      addImagesI: addImagesS.asObserver(),
                      imagesI: imageS.asObserver(),
                      simpanI: simpanS.asObserver())
        
        let back = backS
            .flatMap({ navigator.back() })
            .asDriverOnErrorJustComplete()
        
        let addImages = addImagesS
            .asDriverOnErrorJustComplete()
        
        let updatedImages = imageS
            .do(onNext: { [weak self] (stash) in
                guard let `self` = self else { return }
                print("Stash: \(stash)")
                switch stash.section {
                case 0:
                    print("adding images in section 1")
                    var latestValue = self.presidenImageRelay.value
                    latestValue.append(stash)
                    self.presidenImageRelay.accept(latestValue)
                case 1:
                    print("adding images in section 2")
                    var latestValue = self.dprImageRelay.value
                    latestValue.append(stash)
                    self.dprImageRelay.accept(latestValue)
                case 2:
                    print("adding images in section 3")
                    var latestValue = self.dpdImageRelay.value
                    latestValue.append(stash)
                    self.dpdImageRelay.accept(latestValue)
                case 3:
                    print("adding images in section 4")
                    var latestValue = self.dprdProvImageRelay.value
                    latestValue.append(stash)
                    self.dprdProvImageRelay.accept(latestValue)
                case 4:
                    print("adding images in section 5")
                    var latestValue = self.dprdImageRelay.value
                    latestValue.append(stash)
                    self.dprdImageRelay.accept(latestValue)
                case 5:
                    print("adding images in section 6")
                    var latestValue = self.suasanaImageRelay.value
                    latestValue.append(stash)
                    self.suasanaImageRelay.accept(latestValue)
                default: break
                }
            })
            .filter({ $0.images != nil })
            .asDriverOnErrorJustComplete()
        
        
        let save = simpanS
            .do(onNext: { (_) in
            })
            .asDriverOnErrorJustComplete()
        
        output = Output(backO: back, addImageO: addImages,
                        imageUpdatedO: updatedImages,
                        simpanO: save)
    }
}


