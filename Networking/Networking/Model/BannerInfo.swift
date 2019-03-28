//
//  BannerInfo.swift
//  Networking
//
//  Created by wisnu bhakti on 01/01/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import Foundation

public struct BannerInfo: Codable {
    
    public let id: String
    public var pageName: BannerPage
    public var title: String
    public var body: String
    public var headerImage: Image
    public var image: Image
    
    enum CodingKeys: String, CodingKey {
        case id, title, body, image
        case pageName = "page_name"
        case headerImage = "header_image"
    }
    
}

public struct BannerInfoResponse: Codable {
    
    public var bannerInfo: BannerInfo
    
    private enum CodingKeys: String, CodingKey {
        case bannerInfo = "banner_info"
    }
    
}

public enum BannerPage: String, Codable {
    case pilpres = "pilpres"
    case janji_politik = "janji politik"
    case tanya = "tanya"
    case kuis = "kuis"
    case debat_public = "debat_public"
    case debat_personal = "debat_personal"
    case debat = "debat"
    case tantangan = "tantangan"
    case perhitungan = "perhitungan"
    case rekapitulasi = "rekapitulasi"
    case unknown
    
    public var text: String {
        switch self {
        case .pilpres:
            return "pilpres"
        case .janji_politik:
            return "janji politik"
        case .tanya:
            return "tanya"
        case .kuis:
            return "Kuis"
        case .debat_public:
            return "Debat"
        case .debat_personal:
            return "Tantangan"
        case .debat:
            return "debat"
        case .tantangan:
            return "tantangan"
        case .perhitungan:
            return "perhitungan"
        case .rekapitulasi:
            return "rekapitulasi"
        default:
            return ""
        }
    }
    
    public static func type(title: String?) -> BannerPage {
        guard let title = title else { return .unknown }
        switch title {
        case "Pilpres":
            return .pilpres
        case "Janji Politik":
            return .janji_politik
        case "Tanya":
            return .tanya
        case "Kuis":
            return .kuis
        case "Debat":
            return .debat_public
        case "Tantangan":
            return .tantangan
        case "Perhitungan":
            return .perhitungan
        case "Rekapitulasi":
            return .rekapitulasi
        default:
            return .unknown
        }
    }
}
