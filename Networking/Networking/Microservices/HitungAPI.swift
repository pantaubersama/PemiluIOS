//
//  HitungAPI.swift
//  Networking
//
//  Created by Nanang Rafsanjani on 12/03/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import Moya
import Common

public enum TingkatPemilihan: String {
    case dpr = "dpr"
    case provinsi = "provinsi"
    case kabupaten = "kabupaten"
    case dpd = "dpd"
    case presiden = "presiden"
}

public enum RealCountImageType: String {
    case c1Presiden = "c1_presiden"
    case c1DPR = "c1_dpr_ri"
    case c1DPD = "c1_dpd"
    case c1DPRDProvinsi = "c1_dprd_provinsi"
    case c1DPRDKabupaten = "c1_dprd_kabupaten"
    case suasanaTPS = "suasana_tps"
}

public enum HitungAPI {
    case getCalculations(hitungRealCountId: String, tingkat: TingkatPemilihan)
    case putCalculations(hitungRealCountId: String, type: TingkatPemilihan, invalidVote: Int, candidates: [CandidatesCount], parties: [CandidatesCount]?)
    
    case getCandidates(tingkat: TingkatPemilihan)
    case getProvinces(page: Int, perPage: Int)
    case getRegencies(page: Int, perPage: Int, provinceCode: Int)
    case getDistricts(page: Int, perPage: Int, regencyCode: Int)
    case getDapils(provinceCode: Int, regenciCode: Int, districtCode: Int, tingkat: TingkatPemilihan)
    case getSuasanaTPS(page: Int, perPage: Int)
    case getContribution
    case getVillages(page: Int, perPage: Int, districtCode: Int)
    
    case getFormC1(hitungRealCountId: Int, tingkat: TingkatPemilihan)
    case putFormC1(parameters: [String: Any])
    
    case deleteImages(id: Int)
    case getImages(id: Int)
    case getImagesRealCount(hitungRealCountId: Int)
    case postImageRealCount(hitungRealCountId: Int, type: RealCountImageType, image: UIImage)
    
    case putRealCount(id: Int, noTps: Int)
    case getRealCount(id: Int)
    case getRealCounts(page: Int, perPage: Int, userId: String?, villageCode: String?, dapilId: String?)
    case postRealCount(noTps: String, province: String, regencies: String, district: String, village: String, lat: Double, long: Double)
    case publishRealCount(id: String)
}

extension HitungAPI: TargetType {
    
    public var headers: [String : String]? {
        let token = KeychainService.load(type: NetworkKeychainKind.token) ?? ""
        print("tokenx \(token)")        
        return [
            "Content-Type"  : "application/json",
            "Accept"        : "application/json",
            "Authorization" : token
        ]
    }
    
    public var baseURL: URL {
        return URL(string: AppContext.instance.infoForKey("URL_API_PEMILU"))!
    }
    
    public var path: String {
        switch self {
        case .getRealCount(let id),
             .putRealCount(let id, _):
            return "/hitung/v1/real_counts/\(id)"
        case .getRealCounts,
             .postRealCount:
            return "/hitung/v1/real_counts"
        case .publishRealCount(let id):
            return "/hitung/v1/real_counts/\(id)/draft"
        case .getCalculations,
             .putCalculations:
            return "/hitung/v1/calculations"
        case .getCandidates:
            return "/hitung/v1/candidates"
        case .getDapils:
            return "/hitung/v1/dapils"
        case .getDistricts:
            return "/hitung/v1/districts"
        case .getSuasanaTPS:
            return "/hitung/v1/images/suasana_tps"
        case .getProvinces:
            return "/hitung/v1/provinces"
        case .getRegencies:
            return "/hitung/v1/regencies"
        case .getContribution:
            return "/hitung/v1/summary/contribution"
        case .getVillages:
            return "/hitung/v1/villages"
        case .getFormC1,
             .putFormC1:
            return "/hitung/v1/form_c1"
        case .getImages(let id),
             .deleteImages(let id):
            return "/hitung/v1/images/\(id)"
        case .getImagesRealCount,
             .postImageRealCount:
            return "/hitung/v1/images"
        }
    }
    
    public var method: Moya.Method {
        switch self {
        case .postImageRealCount,
             .postRealCount,
             .publishRealCount:
            return .post
        case .deleteImages:
            return .delete
        case .putCalculations,
             .putFormC1,
             .putRealCount:
            return .put
        default:
            return .get
        }
    }
    
    public var multipartBody: [MultipartFormData]? {
        switch self {
            
        case .postImageRealCount(let hitungRealCountId, let type, let image):
            var multipartFormData = [MultipartFormData]()
            multipartFormData.append(buildMultipartFormData(key: "hitung_real_count_id", value: "\(hitungRealCountId)"))
            multipartFormData.append(buildMultipartFormData(key: "image_type", value: type.rawValue))
            if let image = image.jpegData(compressionQuality: 0.1) {
                multipartFormData.append(buildMultipartFormData(name: "file", value: image))
            }
            return multipartFormData
        case .putCalculations(let (realCountId, type, invalidVote, candidates, parties)):
            var multipartFormData = [MultipartFormData]()
            multipartFormData.append(buildMultipartFormData(key: "hitung_real_count_id", value: realCountId))
            multipartFormData.append(buildMultipartFormData(key: "calculation_type", value: type.rawValue))
            multipartFormData.append(buildMultipartFormData(key: "invalid_vote", value: "\(invalidVote)"))
            for candidate in candidates {
                multipartFormData.append(buildMultipartFormData(key: "candidates[][id]", value: "\(candidate.id)"))
                multipartFormData.append(buildMultipartFormData(key: "candidates[][total_vote]", value: "\(candidate.totalVote)"))
            }
            if let partie = parties {
                for parties in partie {
                    multipartFormData.append(buildMultipartFormData(key: "parties[][id]", value: "\(parties.id)"))
                    multipartFormData.append(buildMultipartFormData(key: "parties[][total_vote]", value: "\(parties.totalVote)"))
                }
            }
            return multipartFormData
        default:
            return nil
        }
    }
    
    public var parameters: [String: Any]? {
        switch self {
        case .getCalculations(let (hitungRealCountId, tingkat)):
            return [
                "hitung_real_count_id": hitungRealCountId,
                "calculation_type": tingkat.rawValue
            ]
        case .postRealCount(let (noTps, province, regencies, district, village, lat, long)):
            return [
                "tps": noTps,
                "province_code": province,
                "regency_code": regencies,
                "district_code": district,
                "village_code": village,
                "latitude": lat,
                "longitude": long
            ]
        case .putRealCount(let id, let noTps):
            return [
                "tps": noTps,
                "id": id
            ]
        case .getRealCount(let id):
            return ["id": id]
        case .getRealCounts(let page, let perPage, let userId, let villageCode, let dapilId):
            var params: [String: Any] = [
                "page": page,
                "per_page": perPage
            ]
            params["user_id"] = userId
            params["village_code"] = villageCode
            params["dapil_id"] = dapilId
            return params
        case .publishRealCount(let id):
            return ["id": id]
        case .getDapils(let provinceCode, let regenciCode, let districtCode, let tingkat):
            return [
                "province_code": provinceCode,
                "regency_code": regenciCode,
                "district_code": districtCode,
                "tingkat": tingkat.rawValue
            ]
        case .getDistricts(let page, let perPage, let regencyCode):
            return [
                "page": page,
                "per_page": perPage,
                "regency_code": regencyCode
            ]
        case .getSuasanaTPS(let page, let perPage):
            return [
                "page": page,
                "per_page": perPage
            ]
        case .getProvinces(let page, let perPage):
            return [
                "page": page,
                "per_page": perPage
            ]
        case .getRegencies(let page, let perPage, let provinceCode):
            return [
                "page": page,
                "per_page": perPage,
                "province_code": provinceCode
            ]
        case .getVillages(let page, let perPage, let districtCode):
            return [
                "page": page,
                "per_page": perPage,
                "district_code": districtCode
            ]
        case .getFormC1(let hitungRealCountId, let tingkat):
            return [
                "hitung_real_count_id": hitungRealCountId,
                "form_c1_type": tingkat.rawValue
            ]
        case .putFormC1(let parameters):
            return parameters
        case .getImagesRealCount(let hitungRealCountId):
            return ["hitung_real_count_id": hitungRealCountId]
            
        default:
            return nil
        }
    }
    
    public var parameterEncoding: ParameterEncoding {
        switch self.method {
        case .put, .post:
            return JSONEncoding.default
        default:
            return URLEncoding.default
        }
    }
    
    public var task: Task {
        switch self {
        case .postImageRealCount,
             .postRealCount,
             .putCalculations:
            return .uploadMultipart(self.multipartBody ?? [])
        default:
            return .requestParameters(parameters: parameters ?? [:], encoding: parameterEncoding)
        }
    }
    
    public var validate: Bool {
        switch self {
        default:
            return false
        }
    }
    
    public var sampleData: Data {
        return Data()
    }
    
}

extension HitungAPI {
    private func buildMultipartFormData(key: String, value: String) -> MultipartFormData {
        return MultipartFormData(provider: .data(value.data(using: String.Encoding.utf8, allowLossyConversion: true)!), name: key)
    }
    
    private func buildMultipartFormData(name: String? = nil, value: Data) -> MultipartFormData {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "ddMMyyyyHHmmss"
        return MultipartFormData(provider: .data(value), name: name ?? "image[]", fileName: "pantau-ios-\(dateFormatter.string(from: Date())).jpg", mimeType:"image/jpeg")
    }
}
