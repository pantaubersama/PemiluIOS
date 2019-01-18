//
//  SectionOfProfileInfoData.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 25/12/18.
//  Copyright © 2018 PantauBersama. All rights reserved.
//

import Foundation
import RxDataSources

enum FieldType {
    case text
    case password
    case date
    case number
    case username
    case dropdown
    case gender
}

enum key: Int {
    case fullName
    case username
    case lokasi
    case about
    case pendidikan
    case pekerjaan
    case sandiLama
    case sandiBaru
    case sandiKonfirmasi
    case identitas
    case pob
    case dob
    case gender
    case nationality
    case address
    case phone
    
    var title: String {
        switch self {
        case .fullName:
            return "Nama Lengkap"
        case .username:
            return "Username"
        case .lokasi:
            return "Lokasi"
        case .about:
            return "Bio"
        case .pendidikan:
            return "Pendidikan"
        case .pekerjaan:
            return "Pekerjaan"
        case .sandiLama:
            return "Masukan Kata Sandi Lama"
        case .sandiBaru:
            return "Kata Sandi Baru"
        case .sandiKonfirmasi:
            return "Konfirmasi Kata Sandi Baru"
        case .identitas:
            return "No KTP/SIM/Pasport"
        case .pob:
            return "Tempat Lahir"
        case .dob:
            return "Tanggal Lahir"
        case .gender:
            return "Jenis Kelamin"
        case .nationality:
            return "Kewarganegaraan"
        case .address:
            return "Alamat"
        case .phone:
            return "No Telp/HP"
        }
    }
    
}

struct ProfileInfoField {
    let key: key
    var value: String?
    let fieldType: FieldType
    let parameter: String
}

struct SectionOfProfileInfoData {
    let id: String
    var items: [Item]
    var header: ProfileHeaderItem
}

extension SectionOfProfileInfoData: SectionModelType {
    typealias Item = ProfileInfoField
    
    init(original: SectionOfProfileInfoData, items: [ProfileInfoField]) {
        self = original
        self.items = items
    }
}

