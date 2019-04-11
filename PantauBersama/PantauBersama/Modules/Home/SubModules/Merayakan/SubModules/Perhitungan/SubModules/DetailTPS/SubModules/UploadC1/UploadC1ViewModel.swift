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
        let refreshI: AnyObserver<String>
        let nextI: AnyObserver<Void>
        let deleteImagesI: AnyObserver<String>
    }
    
    struct Output {
        let backO: Driver<Void>
        let addImageO: Driver<Int>
        let imageUpdatedO: Driver<StashImages>
        let simpanO: Driver<Void>
        let initialDataO: Driver<[SectionC1Models]>
        let errorO: Driver<Error>
        let deletedImagesO: Driver<Void>
    }
    
    var input: Input
    var output: Output!
    
    private let navigator: UploadC1Navigator
    private let realCount: RealCount
    private let errorTracker = ErrorTracker()
    private let activityIndicator = ActivityIndicator()
    
    private let backS = PublishSubject<Void>()
    private let addImagesS = PublishSubject<Int>()
    private let imageS = PublishSubject<StashImages>()
    private let simpanS = PublishSubject<Void>()
    private let refreshS = PublishSubject<String>()
    private let nextS = PublishSubject<Void>()
    private let deleteImageS = PublishSubject<String>()
    
    var presidenImageRelay = BehaviorRelay<[StashImages]>(value: [])
    var dprImageRelay = BehaviorRelay<[StashImages]>(value: [])
    var dpdImageRelay = BehaviorRelay<[StashImages]>(value: [])
    var dprdProvImageRelay = BehaviorRelay<[StashImages]>(value: [])
    var dprdImageRelay = BehaviorRelay<[StashImages]>(value: [])
    var suasanaImageRelay = BehaviorRelay<[StashImages]>(value: [])
    var relaySections = BehaviorRelay<[SectionC1Models]>(value: [])
    
    init(navigator: UploadC1Navigator, realCount: RealCount) {
        self.navigator = navigator
        self.realCount = realCount
        
        input = Input(backI: backS.asObserver(),
                      addImagesI: addImagesS.asObserver(),
                      imagesI: imageS.asObserver(),
                      simpanI: simpanS.asObserver(),
                      refreshI: refreshS.asObserver(),
                      nextI: nextS.asObserver(),
                      deleteImagesI: deleteImageS.asObserver())
        
        /// MARK: GET Initial Data
        let initialData = refreshS.startWith("")
            .flatMapLatest { [weak self] (_) -> Observable<[SectionC1Models]> in
                guard let `self` = self else { return Observable.empty() }
                return self.paginateItems(nextBatchTrigger: self.nextS.asObservable(), type: .c1Presiden)
                    .map({ [weak self] (data) -> [SectionC1Models] in
                        guard let `self` = self else { return [] }
                        return self.transformToSection(data: data, type: .c1Presiden)
                    })
                    
                    .trackActivity(self.activityIndicator)
                    .trackError(self.errorTracker)
                    .asObservable()
                    .catchErrorJustReturn([])
            }
            .flatMapLatest { [weak self] (section) -> Observable<[SectionC1Models]> in
                guard let `self` = self else { return Observable.empty()
                }
                return self.paginateItems(nextBatchTrigger: self.nextS.asObservable(), type: .c1DPR)
                    .map({ [weak self] (data) -> [SectionC1Models] in
                        guard let `self` = self else { return [] }
                        return section + self.transformToSection(data: data, type: .c1DPR)
                    })
                    .trackActivity(self.activityIndicator)
                    .trackError(self.errorTracker)
                    .asObservable()
                    .catchErrorJustReturn([])
            }
            .flatMapLatest { [weak self] (section) -> Observable<[SectionC1Models]> in
                guard let `self` = self else { return Observable.empty() }
                return self.paginateItems(nextBatchTrigger: self.nextS.asObservable(), type: .c1DPD)
                    .map({ [weak self] (data) -> [SectionC1Models] in
                        guard let `self` = self else { return [] }
                        return section + self.transformToSection(data: data, type: .c1DPD)
                    })
                    .trackActivity(self.activityIndicator)
                    .trackError(self.errorTracker)
                    .asObservable()
                    .catchErrorJustReturn([])
            }
            .flatMapLatest { [weak self] (section) -> Observable<[SectionC1Models]> in
                guard let `self` = self else { return Observable.empty() }
                return self.paginateItems(nextBatchTrigger: self.nextS.asObservable(), type: .c1DPRDProvinsi)
                    .map({ [weak self] (data) -> [SectionC1Models] in
                        guard let `self` = self else { return [] }
                        return section + self.transformToSection(data: data, type: .c1DPRDProvinsi)
                    })
                    .trackActivity(self.activityIndicator)
                    .trackError(self.errorTracker)
                    .asObservable()
                    .catchErrorJustReturn([])
            }
            .flatMapLatest { [weak self] (section) -> Observable<[SectionC1Models]> in
                guard let `self` = self else { return Observable.empty() }
                return self.paginateItems(nextBatchTrigger: self.nextS.asObservable(), type: .c1DPRDKabupaten)
                    .map({ [weak self] (data) -> [SectionC1Models] in
                        guard let `self` = self else { return [] }
                        return section + self.transformToSection(data: data, type: .c1DPRDKabupaten)
                    })
                    .trackActivity(self.activityIndicator)
                    .trackError(self.errorTracker)
                    .asObservable()
                    .catchErrorJustReturn([])
            }
            .flatMapLatest { [weak self] (section) -> Observable<[SectionC1Models]> in
                guard let `self` = self else { return Observable.empty() }
                return self.paginateItems(nextBatchTrigger: self.nextS.asObservable(), type: .suasanaTPS)
                    .map({ [weak self] (data) -> [SectionC1Models] in
                        guard let `self` = self else { return [] }
                        return section + self.transformToSection(data: data, type: .suasanaTPS)
                    })
                    .trackActivity(self.activityIndicator)
                    .trackError(self.errorTracker)
                    .asObservable()
                    .catchErrorJustReturn([])
            }.asDriver(onErrorJustReturn: [SectionC1Models(header: "1. Model C1-PPWP (Presiden)", items: []),
                                           SectionC1Models(header: "2. Model C1-DPR RI", items: []),
                                           SectionC1Models(header: "3. Model C1-DPD", items: []),
                                           SectionC1Models(header: "4. Model C1-DPRD Provinsi", items: []),
                                           SectionC1Models(header: "5. Model C1-DPRD Kabupaten/Kota", items: []),
                                           SectionC1Models(header: "6. Suasana TPS", items: [])])
        
        
        let back = backS
            .flatMap({ navigator.back() })
            .asDriverOnErrorJustComplete()
        
        let addImages = addImagesS
            .asDriverOnErrorJustComplete()
        
        let updatedImages = imageS
            .do(onNext: { [weak self] (stash) in
                guard let `self` = self else { return }
                print("Stash Images: \(stash)")
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
            .filter({ $0.section != 7 })
            .asDriverOnErrorJustComplete()
        
        
        let save = simpanS
            .do(onNext: { (_) in
                print("IMAGES COUNT: \(self.dprdImageRelay.value.count)")
            })
            .flatMapLatest({ [weak self] (_) -> Observable<Void> in
                guard let `self` = self else { return Observable.empty() }
                let presidenValue = self.presidenImageRelay.value
                let stashImage = presidenValue.filter({ $0.url == nil })
                print("Stash count original pic: \(stashImage.count)")
                for stash in stashImage {
                    if let image = stash.images {
                        return self.postImages(realCount: realCount.id, type: .c1Presiden, image: image)
                    }
                }
                return Observable.just(())
            })
            .flatMapLatest({ [weak self] (_) -> Observable<Void> in
                guard let `self` = self else { return Observable.empty() }
                let dprValue = self.dprImageRelay.value
                let stashImage = dprValue.filter({ $0.url == nil })
                for stash in stashImage {
                    if let image = stash.images {
                        return self.postImages(realCount: realCount.id, type: .c1DPR, image: image)
                    }
                }
                return Observable.just(())
            })
            .flatMapLatest({ [weak self] (_) -> Observable<Void> in
                guard let `self` = self else { return Observable.empty() }
                let dpdValue = self.dpdImageRelay.value
                let stashImage = dpdValue.filter({ $0.url == nil })
                for stash in stashImage {
                    if let image = stash.images {
                        return self.postImages(realCount: realCount.id, type: .c1DPD, image: image)
                    }
                }
                return Observable.just(())
            })
            .flatMapLatest({ [weak self] (_) -> Observable<Void> in
                guard let `self` = self else { return Observable.empty() }
                let dprdProvValue = self.dprdProvImageRelay.value
                let stashImage = dprdProvValue.filter({ $0.url == nil })
                for stash in stashImage {
                    if let image = stash.images {
                        return self.postImages(realCount: realCount.id, type: .c1DPRDProvinsi, image: image)
                    }
                }
                return Observable.just(())
            })
            .flatMapLatest({ [weak self] (_) -> Observable<Void> in
                guard let `self` = self else { return Observable.empty() }
                let dprdKab = self.dprdImageRelay.value
                let stashImage = dprdKab.filter({ $0.url == nil })
                for stash in stashImage {
                    if let image = stash.images {
                        return self.postImages(realCount: realCount.id, type: .c1DPRDKabupaten, image: image)
                    }
                }
                return Observable.just(())
            })
            .flatMapLatest({ [weak self] (_) -> Observable<Void> in
                guard let `self` = self else { return Observable.empty() }
                let suasanaValue = self.suasanaImageRelay.value
                let stashImage = suasanaValue.filter({ $0.url == nil })
                for stash in stashImage {
                    if let image = stash.images {
                        return self.postImages(realCount: realCount.id, type: .suasanaTPS, image: image)
                    }
                }
                return Observable.just(())
            })
            .asDriverOnErrorJustComplete()
        
        let delete = deleteImageS
            .flatMapLatest { [weak self] (id) -> Observable<Void> in
                guard let `self` = self else { return Observable.empty() }
                return self.deleteImages(id: id)
            }.asDriverOnErrorJustComplete()
        
        output = Output(backO: back, addImageO: addImages,
                        imageUpdatedO: updatedImages,
                        simpanO: save,
                        initialDataO: initialData,
                        errorO: errorTracker.asDriver(),
                        deletedImagesO: delete)
    }
}

extension UploadC1ViewModel {
    
    private func paginateItems(
        batch: Batch = Batch.initial,
        nextBatchTrigger: Observable<Void>,
        type: RealCountImageType) -> Observable<[ImageResponse]> {
        return recursivelyPaginateItems(batch: batch, nextBatchTrigger: nextBatchTrigger, type: type)
            .scan([], accumulator: { (accumulator, page) in
                return accumulator + page.item
            })
    }
    
    private func recursivelyPaginateItems(
        batch: Batch,
        nextBatchTrigger: Observable<Void>,
        type: RealCountImageType) -> Observable<Page<[ImageResponse]>> {
        return NetworkService.instance
            .requestObject(HitungAPI
                .getImagesRealCount(hitungRealCountId: realCount.id,
                                    type: type,
                                    page: batch.page,
                                    perPage: batch.offset),
                           c: BaseResponse<SummaryImageResponse>.self)
            .map({ self.transformToPage(response: $0, batch: batch)})
            .asObservable()
            .paginate(nextPageTrigger: nextBatchTrigger, hasNextPage: { (result) -> Bool in
                return result.batch.next().hasNextPage
            }, nextPageFactory: { (result) -> Observable<Page<[ImageResponse]>> in
                self.recursivelyPaginateItems(batch: result.batch.next(), nextBatchTrigger: nextBatchTrigger, type: type)
            })
    }
    
    private func transformToPage(response: BaseResponse<SummaryImageResponse>, batch: Batch) -> Page<[ImageResponse]> {
        let nextBatch = Batch(offset: batch.offset,
                              limit: response.data.meta.pages.perPage ?? 10,
                              total: response.data.meta.pages.total,
                              count: response.data.meta.pages.page,
                              page: response.data.meta.pages.page)
        return Page<[ImageResponse]>(
            item: response.data.image,
            batch: nextBatch
        )
    }
    
    private func transformToSection(data: [ImageResponse], type: RealCountImageType) -> [SectionC1Models] {
        var latestValue = self.relaySections.value
        
        switch type {
        case .c1Presiden:
            for datas in data {
                self.imageS.onNext(StashImages(section: 0, images: nil, id: datas.id, url: datas.file.thumbnail.url))
            }
            latestValue.append(SectionC1Models(header: "1. Model C1-PPWP (Presiden)", items: []))
            self.relaySections.accept(latestValue)
        case .c1DPR:
            for datas in data {
                self.imageS.onNext(StashImages(section: 1, images: #imageLiteral(resourceName: "outlineImage24Px"), id: datas.id, url: datas.file.thumbnail.url))
            }
            latestValue.append(SectionC1Models(header: "2. Model C1-DPR RI", items: []))
            self.relaySections.accept(latestValue)
        case .c1DPD:
            for datas in data {
                self.imageS.onNext(StashImages(section: 2, images: #imageLiteral(resourceName: "outlineImage24Px"), id: datas.id, url: datas.file.thumbnail.url))
            }
            latestValue.append(SectionC1Models(header: "3. Model C1-DPD", items: []))
            self.relaySections.accept(latestValue)
        case .c1DPRDProvinsi:
            for datas in data {
                self.imageS.onNext(StashImages(section: 3, images: #imageLiteral(resourceName: "outlineImage24Px"), id: datas.id, url: datas.file.thumbnail.url))
            }
            latestValue.append(SectionC1Models(header: "4. Model C1-DPRD Provinsi", items: []))
            self.relaySections.accept(latestValue)
        case .c1DPRDKabupaten:
            for datas in data {
                self.imageS.onNext(StashImages(section: 4, images: #imageLiteral(resourceName: "outlineImage24Px"), id: datas.id, url: datas.file.thumbnail.url))
            }
            latestValue.append(SectionC1Models(header: "5. Model C1-DPRD Kabupaten/Kota", items: []))
            self.relaySections.accept(latestValue)
        case .suasanaTPS:
            for datas in data {
                self.imageS.onNext(StashImages(section: 5, images: #imageLiteral(resourceName: "outlineImage24Px"), id: datas.id, url: datas.file.thumbnail.url))
            }
            latestValue.append(SectionC1Models(header: "6. Suasana TPS", items: []))
            self.relaySections.accept(latestValue)
        }
        
        print("Total Relay: \(latestValue.count)")
        return self.relaySections.value
    }
    
    private func postImages(realCount: String, type: RealCountImageType, image: UIImage) -> Observable<Void> {
        return NetworkService.instance
            .requestObject(HitungAPI.postImageRealCount(hitungRealCountId: realCount, type: type, image: image),
                           c: BaseResponse<PostImageResponse>.self)
            .do(onSuccess: { (response) in
                print("Status Upload: \(response.data.status)")
            }, onError: { (e) in
                print(e.localizedDescription)
            })
            .trackError(self.errorTracker)
            .trackActivity(self.activityIndicator)
            .mapToVoid()
            .asObservable()
    }
    
    private func deleteImages(id: String) -> Observable<Void> {
        return NetworkService.instance
            .requestObject(HitungAPI.deleteImages(id: id), c: BaseResponse<PostImageResponse>.self)
            .do(onSuccess: { (response) in
                print("Status delete: \(response.data.status)")
            }, onError: { (e) in
                print(e.localizedDescription)
            })
            .trackError(self.errorTracker)
            .trackActivity(self.activityIndicator)
            .mapToVoid()
            .asObservable()
    }
}
