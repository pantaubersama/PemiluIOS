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
        let imagesI: AnyObserver<UIImage?>
    }
    
    struct Output {
        let backO: Driver<Void>
        let addImageO: Driver<Int>
        let imageUpdatedO: Driver<StashImages>
    }
    
    var input: Input
    var output: Output!
    
    private let navigator: UploadC1Navigator
    private let backS = PublishSubject<Void>()
    
    private let addImagesS = PublishSubject<Int>()
    private let imageS = PublishSubject<UIImage?>()
    
    
    var presidenImageRelay = BehaviorRelay<[ImageResponse]>(value: [])
    var dprImageRelay = BehaviorRelay<[ImageResponse]>(value: [])
    var dpdImageRelay = BehaviorRelay<[ImageResponse]>(value: [])
    var dprdImageRelay = BehaviorRelay<[ImageResponse]>(value: [])
    var suasanaImageRelay = BehaviorRelay<[ImageResponse]>(value: [])
    var relayImages = BehaviorRelay<StashImages>(value: StashImages(section: 0, images: nil, id: nil))
    
    init(navigator: UploadC1Navigator) {
        self.navigator = navigator
        
        input = Input(backI: backS.asObserver(),
                      addImagesI: addImagesS.asObserver(),
                      imagesI: imageS.asObserver())
        
        let back = backS
            .flatMap({ navigator.back() })
            .asDriverOnErrorJustComplete()
        
        let addImages = addImagesS
            .asDriverOnErrorJustComplete()
        
        let updatedImages = Observable.combineLatest(imageS.asObservable(), addImagesS.asObservable())
            .do(onNext: { [weak self] (image, section) in
                guard let `self` = self else { return }
                self.relayImages.accept(StashImages(section: section, images: image, id: UUID().uuidString))
            })
            .map { (image, section) -> StashImages in
                return StashImages(section: section, images: image, id: UUID().uuidString)
        }.asDriverOnErrorJustComplete()
        
        
        output = Output(backO: back, addImageO: addImages,
                        imageUpdatedO: updatedImages)
    }
}


