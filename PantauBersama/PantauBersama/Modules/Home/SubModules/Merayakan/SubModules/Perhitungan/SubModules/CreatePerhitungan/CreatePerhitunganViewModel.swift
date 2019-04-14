//
//  CreatePerhitunganViewModel.swift
//  PantauBersama
//
//  Created by Rahardyan Bisma on 25/02/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import Foundation
import Common
import RxSwift
import RxCocoa
import Networking
import RxCoreLocation
import CoreLocation

class CreatePerhitunganViewModel: ViewModelType {
    struct Input {
        let tpsNoI: AnyObserver<String>
        let provinceI: AnyObserver<String>
        let regenciesI: AnyObserver<String>
        let districtI: AnyObserver<String>
        let villageI: AnyObserver<String>
        let detailTPSI: AnyObserver<Void>
        let backI: AnyObserver<Void>
        let refreshI: AnyObserver<String>
    }
    
    struct Output {
        let createO: Driver<Void>
        let backO: Driver<Void>
        let enableO: Driver<Bool>
        let errorO: Driver<Error>
        let initialDataO: Driver<RealCount?>
    }
    
    var input: Input
    var output: Output!
    
    private let bag = DisposeBag()
    private let navigator: CreatePerhitunganNavigator
    private let noTpsS = PublishSubject<String>()
    private let provinceS = PublishSubject<String>()
    private let districtS = PublishSubject<String>()
    private let regenciesS = PublishSubject<String>()
    private let villageS = PublishSubject<String>()
    private let backS = PublishSubject<Void>()
    private let detailTPSS = PublishSubject<Void>()
    private let manager = CLLocationManager()
    private let refreshS = PublishSubject<String>()
    
    var provinces = [Province]()
    var regencies = [Regency]()
    var districts = [District]()
    var villages = [Village]()
    var coordinate = BehaviorRelay(value: CLLocationCoordinate2D())
    var formattedAddress = BehaviorRelay(value: "")

    
    private var errorTracker = ErrorTracker()
    private var activityIndicator = ActivityIndicator()
    private let data: RealCount?
    var isEdit: Bool
    
    init(navigator: CreatePerhitunganNavigator, data: RealCount? = nil, isEdit: Bool) {
        self.navigator = navigator
        let errorTracker = ErrorTracker()
        let activityIndicator = ActivityIndicator()
        self.data = data
        self.isEdit = isEdit
        
        input = Input(
            tpsNoI: noTpsS.asObserver(),
            provinceI: provinceS.asObserver(),
            regenciesI: regenciesS.asObserver(),
            districtI: districtS.asObserver(),
            villageI: villageS.asObserver(),
            detailTPSI: detailTPSS.asObserver(),
            backI: backS.asObserver(),
            refreshI: refreshS.asObserver())
        
        let back = backS
            .flatMap({ navigator.back() })
            .asDriverOnErrorJustComplete()
        
        let enablePost = Observable.combineLatest(noTpsS, provinceS, regenciesS, districtS, villageS)
            .map { (noTps, province, regencies, district, village) -> Bool in
                return noTps.count > 0 && province.count > 0 && district.count > 0 && village.count > 0
            }
            .startWith(false)
            .asDriverOnErrorJustComplete()
        
        let done = detailTPSS
            .withLatestFrom(Observable.combineLatest(noTpsS, provinceS, regenciesS, districtS, villageS))
            .flatMapLatest({ (noTps, province, regencies, district, village) in
                return NetworkService.instance.requestObject(
                    HitungAPI.postRealCount(noTps: noTps, province: province, regencies: regencies, district: district, village: village, lat: self.coordinate.value.latitude, long: self.coordinate.value.longitude),
                    c: BaseResponse<CreateTpsResponse>.self)
                    .trackError(errorTracker)
                    .trackActivity(activityIndicator)
                    .catchErrorJustComplete()
            })
            .map { (response) in
                navigator.launchDetailTPS(realCount: response.data.realCount)
            }
            .mapToVoid().asDriverOnErrorJustComplete()
        
        /// MARK: Just edit number TPS
        let edit = detailTPSS
            .withLatestFrom(noTpsS)
            .flatMapLatest({ [weak self] (noTps) -> Observable<Void> in
                guard let `self` = self else { return Observable.empty() }
                if let realCount =  self.data {
                    print("data: ID: \(realCount.id)")
                    print("no tps: \(noTps)")
                    return NetworkService.instance
                        .requestObject(HitungAPI.putRealCount(id: realCount.id, noTps: Int(noTps)!),
                                       c: BaseResponse<CreateTpsResponse>.self)
                        .trackError(self.errorTracker)
                        .trackActivity(self.activityIndicator)
                        .mapToVoid()
                        .catchErrorJustComplete()
                } else {
                    return Observable.empty()
                }
            })
            .map { (_) in
                navigator.back()
            }
            .mapToVoid()
            .asDriverOnErrorJustComplete()
        
        
        output = Output(
            createO: self.isEdit ? edit : done,
            backO: back,
            enableO: enablePost,
            errorO: errorTracker.asDriver(),
            initialDataO: Driver.just(data))
        
        manager.requestWhenInUseAuthorization()
        
        manager.rx
            .placemark
            .map({ $0.formattedAddress })
            .bind(to: formattedAddress)
            .disposed(by: bag)
        
        manager.rx
            .location
            .map({ $0?.coordinate ?? CLLocationCoordinate2D() })
            .bind(to: coordinate)
            .disposed(by: bag)
    }
    
    func selectProvince(_ province: Province) {
        self.input.provinceI.onNext("\(province.code)")
        getRegencies(provinceCode: province.code)
    }
    
    func selectRegency(_ reg: Regency) {
        self.input.regenciesI.onNext("\(reg.code)")
        getDistricts(regencyCode: reg.code)
    }
    
    func selectDistrict(_ dis: District) {
        self.input.districtI.onNext("\(dis.code)")
        getVillages(districtCode: dis.code)
    }
    
    func selectVillage(_ vill: Village) {
        self.input.villageI.onNext("\(vill.code)")
    }
    
    func updateLocation() {
        manager.startUpdatingLocation()
    }
    
    func getProvinces() {
        NetworkService
            .instance
            .requestObject(HitungAPI.getProvinces(page: 1, perPage: 0), c: BaseResponse<ProvinceResponse>.self)
            .map({ $0.data.provinces })
            .subscribe(onSuccess: { [weak self] (result) in
                self?.provinces = result
            })
            .disposed(by: bag)
    }

    private func getRegencies(provinceCode: Int) {
        return NetworkService
            .instance
            .requestObject(HitungAPI.getRegencies(page: 1, perPage: 0, provinceCode: provinceCode), c: BaseResponse<RegencyResponse>.self)
            .map({ $0.data.regencies })
            .subscribe(onSuccess: { [weak self] (result) in
                self?.regencies = result
            })
            .disposed(by: bag)
    }
    
    private func getDistricts(regencyCode: Int) {
        return NetworkService
            .instance
            .requestObject(HitungAPI.getDistricts(page: 1, perPage: 0, regencyCode: regencyCode), c: BaseResponse<DistrictResponse>.self)
            .map({ $0.data.districts })
            .subscribe(onSuccess: { [weak self] (result) in
                self?.districts = result
            })
            .disposed(by: bag)
    }
    
    private func getVillages(districtCode: Int) {
        return NetworkService
            .instance
            .requestObject(HitungAPI.getVillages(page: 1, perPage: 0, districtCode: districtCode), c: BaseResponse<VillageResponse>.self)
            .map({ $0.data.villages })
            .subscribe(onSuccess: { [weak self] (result) in
                self?.villages = result
            })
            .disposed(by: bag)
    }
    
}

extension CLPlacemark {
    var formattedAddress: String {
        var result = name ?? ""
        if let addr = thoroughfare {
            result = "\(result), \(addr)"
        }
        if let city = locality {
            result = "\(result), \(city)"
        }
        if let state = administrativeArea {
            result = "\(result), \(state)"
        }
        if let zipcode = postalCode {
            result = "\(result) \(zipcode)"
        }
        return result
    }
}
