//
//  SectionOfProfileEditData.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 25/12/18.
//  Copyright © 2018 PantauBersama. All rights reserved.
//

import Foundation
import RxDataSources
import Common


enum SettingProfile: Int {
    case namaLengkap
    case username
    case lokasi
    case deksripsi
    case pendidikan
    case pekerjaan
    
    var key: String? {
        switch self {
        case .namaLengkap:
            return "Nama Lengkap"
        case .username:
            return "Username"
        case .lokasi:
            return "Lokasi"
        case .deksripsi:
            return "Deskripsi Tentang Kamu"
        case .pendidikan:
            return "Pendidikan"
        case .pekerjaan:
            return "Pekerjaan"
        }
    }
    
    var value: String? {
        switch self {
        default:
            return nil
        }
    }
}


struct SectionOfProfileEditData {
    var items: [Item]
}

extension SectionOfProfileEditData: SectionModelType {
    typealias Item = SettingProfile
    
    init(original: SectionOfProfileEditData, items: [SettingProfile]) {
        self = original
        self.items = items
    }
}
