//
//  SectionOfSettingData.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 25/12/18.
//  Copyright © 2018 PantauBersama. All rights reserved.
//

import Foundation
import RxDataSources
import UIKit

enum SettingData: Int {
    case updateProfile
    case updatePassword
    case updateDataLapor
    case verifikasi
    case badge
    case twitter
    case facebook
    case cluster
    case pusatBantuan
    case pedomanKomunitas
    case tentang
    case rate
    case share
    case logout
    
    var title: String? {
        switch self {
        case .updateProfile:
            return "Ubah Profil"
        case .updatePassword:
            return "Ubah Sandi"
        case .updateDataLapor:
            return "Ubah Data Lapor"
        case .verifikasi:
            return "Verifikasi"
        case .badge:
            return "Badge"
        case .twitter:
            return UserDefaults.Account.get(forKey: .usernameTwitter) ?? "Connect Twitter"
        case .facebook:
            return "Connect Facebook"
        case .cluster:
            return "Undang"
        case .pusatBantuan:
            return "Pusat Bantuan"
        case .pedomanKomunitas:
            return "Pedoman Komunitas"
        case .tentang:
            return "Tentang Pantau Bersama"
        case .rate:
            return "Berikan Nilai Kami"
        case .share:
            return "Bagikan Aplikasi Pantau Bersama"
        case .logout:
            return "Log Out"
        }
    }
    
    var leftIcon: UIImage? {
        switch self {
        case .updateProfile:
            return #imageLiteral(resourceName: "baselineProfile48Px")
        case .updatePassword:
            return #imageLiteral(resourceName: "group1172")
        case .updateDataLapor:
            return #imageLiteral(resourceName: "baselineProfile48Px")
        case .verifikasi:
            return #imageLiteral(resourceName: "blackVerified")
        case .badge:
            return #imageLiteral(resourceName: "group1174")
        case .twitter:
            return #imageLiteral(resourceName: "icTwitterCircle")
        case .facebook:
            return #imageLiteral(resourceName: "facebook")
        default:
            return nil
        }
    }
}

struct SectionOfSettingData {
    var header: String? = nil
    var items: [Item]
}

extension SectionOfSettingData: SectionModelType {
    typealias Item = SettingData
    
    init(original: SectionOfSettingData, items: [SettingData]) {
        self = original
        self.items = items
    }
}
