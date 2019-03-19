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
        let detailTPSI: AnyObserver<Void>
        let backI: AnyObserver<Void>
    }
    
    struct Output {
        let detailTPSO: Driver<Void>
        let backO: Driver<Void>
    }
    
    var input: Input
    var output: Output
    
    private let bag = DisposeBag()
    private let navigator: CreatePerhitunganNavigator
    private let backS = PublishSubject<Void>()
    private let detailTPSS = PublishSubject<Void>()
    private let manager = CLLocationManager()
    
    var provinces = [Province]()
    var regencies = [Regency]()
    var districts = [District]()
    var villages = [Village]()
    var selectedProvince: Province? {
        didSet {
            guard let code = selectedProvince?.code else {
                return
            }
            getRegencies(provinceCode: code)
        }
    }
    var selectedRegency: Regency? {
        didSet {
            guard let code = selectedRegency?.code else {
                return
            }
            getDistricts(regencyCode: code)
        }
    }
    var selectedDistrict: District? {
        didSet {
            guard let code = selectedDistrict?.code else {
                return
            }
            getVillages(districtCode: code)
        }
    }
    var selectedVillage: Village?
    var coordinate = Variable(CLLocationCoordinate2D())
    var formattedAddress = Variable("")
    
    init(navigator: CreatePerhitunganNavigator) {
        self.navigator = navigator
        
        input = Input(
            detailTPSI: detailTPSS.asObserver(),
            backI: backS.asObserver())
        
        let back = backS
            .flatMap({ navigator.back() })
            .asDriverOnErrorJustComplete()
        
        let detail = detailTPSS
            .flatMap({ navigator.launchDetailTPS() })
            .asDriverOnErrorJustComplete()
        
        output = Output(
            detailTPSO: detail,
            backO: back)
        
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
