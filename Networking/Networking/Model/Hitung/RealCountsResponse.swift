//
//  RealCountsResponse.swift
//  Networking
//
//  Created by wisnu bhakti on 21/03/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import Foundation

public struct RealCountsResponse: Codable {
    
    public var realCounts: [RealCount]
    public let meta: Meta
    
    private enum CodingKeys: String, CodingKey {
        case realCounts = "real_counts"
        case meta
    }
    
}

public struct CreateTpsResponse: Codable {
    
    public var realCount: RealCount
    
    private enum CodingKeys: String, CodingKey {
        case realCount = "real_count"
    }
    
}


public struct RealCount: Codable {
    
    public var id : String
    public var tps: Int 
    public var createdAt: String
    public var createdAtWord: CreatedAt
    public var province: Province
    public var provinceCode: Int
    public var regency: Regency
    public var regencyCode: Int
    public var district: District
    public var districtCode: Int
    public var village: Village
    public var villageCode: Int?
    public var latitude: String
    public var longitude: String
    public var status: RealCountStatus
    public var user: User?
    public var logs: Logs?
    
    public init() {
        self.id = ""
        self.tps = 1
        self.createdAt = ""
        self.createdAtWord = CreatedAt(iso8601: "", en: "", id: "")
        self.province = Province(id: 34, code: 34, name: "DAERAH ISTIMEWA YOGYAKARTA", level: 1, domainName: "yogyakartaprov", idWilayah: 41863)
        self.regency = Regency(id: 3404, provinceId: 34, code: 3404, name: "SLEMAN", level: 2, domainName: "slemankab", idWilayah: 42221, idParent: 41863)
        self.district = District(id: 340407, code: 340407, regencyCode: 3404, name: "DEPOK", idParent: 42221, idWilayah: 42259, level: 3)
        self.village = Village(id: 0, code: 0, districtCode: 340407, name: "Condongcatur") ///  integer literal '3404072003' overflows when stored into 'Int'
        self.latitude = ""
        self.longitude = ""
        self.status = RealCountStatus.sandbox
        self.user = nil
        self.logs = nil
        self.provinceCode = 0
        self.regencyCode = 0
        self.districtCode = 0
        self.villageCode = 0
    }
    
    enum CodingKeys: String, CodingKey {
        case id, tps, province, regency, district, village, latitude, longitude, status, user, logs
        case createdAt = "created_at"
        case createdAtWord = "created_at_in_word"
        case provinceCode = "province_code"
        case regencyCode = "regency_code"
        case districtCode = "district_code"
        case villageCode = "village_code"
    }
    
}

public struct Logs: Codable {
    public let calculation: ItemLog
    public let formC1: ItemLog
    public let images: ItemLog
    
    enum CodingKeys: String, CodingKey {
        case calculation, images
        case formC1 = "form_c1"
    }
    
    public struct ItemLog: Codable {
        public let presiden, dprRi, dpd, dprdProvinsi, dprdKabupaten, suasanaTps: Bool?
        
        enum CodingKeys: String, CodingKey {
            case presiden, dpd
            case dprRi = "dpr_ri"
            case dprdProvinsi = "dprd_provinsi"
            case dprdKabupaten = "dprd_kabupaten"
            case suasanaTps = "suasana_tps"
        }
    }
    
}

public enum RealCountStatus: String, Codable {
    case sandbox = "sandbox"
    case draft = "draft"
    case published = "published"

    
    public var text: String {
        switch self {
        case .sandbox:
            return "Uji Coba"
        case .draft:
            return "Belum Dikirim"
        case .published:
            return "Terkirim"
        }
    }
    
}
