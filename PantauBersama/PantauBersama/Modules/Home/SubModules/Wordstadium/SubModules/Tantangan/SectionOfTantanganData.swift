//
//  SectionOfTantanganData.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 12/02/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import Foundation
import RxDataSources
import Networking

enum TantanganData {
    case bidangKajian
    case pernyataan
    case dateTime
    case saldoTime
    case lawanDebat
    
    var title: String? {
        switch self {
        case .bidangKajian:
            return "Bidang kajian"
        case .pernyataan:
            return "Pernyataan"
        case .lawanDebat:
            return "Lawan debat"
        case .dateTime:
            return "Date & Time"
        case .saldoTime:
            return "Saldo waktu"
        }
    }
    
    var subtitle: String? {
        switch self {
        case .bidangKajian:
            return "Pilih Bidang Kajian yang sesuai dengan materi debat kamu. Misal: Ekonomi, Agama, Politik, dan sebagainya."
        case .pernyataan:
            return "Tulis pernyataan yang sesuai dengan Bidang Kajian. Kamu juga bisa menyertakan tautan/link di sini."
        case .lawanDebat:
            return "Undang orang untuk menjadi lawan debat kamu. Undang lawan debatmu dari Symbolic ID, atau mention langsung akun Twitternya."
        case .dateTime:
            return "Tentukan waktu dan tanggal debat yang kamu inginkan. Jangan sampai salah momen, lho! :|"
        case .saldoTime:
            return "Tentukan durasi atau Saldo Waktu debat untuk kamu dan lawan debatmu. Masing-masing akan mendapat bagian yang sama rata."
        }
    }
    
    var rightIcon: UIImage? {
        switch self {
        default:
           return #imageLiteral(resourceName: "outlineHint16Px")
        }
    }
    
    var leftIconActive: UIImage? {
        switch self {
        default:
           return #imageLiteral(resourceName: "checkDone")
        }
    }
    
    var leftIiconUnactive: UIImage? {
        switch self {
        default:
           return #imageLiteral(resourceName: "checkUnactive")
        }
    }
}

enum TantanganType {
    case text
    case date
    case time
    case username
    case kajian
}

struct SectionOfTantanganData {
    var items: [Item]
    var isHide: Bool
    var isActive: Bool
}

extension SectionOfTantanganData: SectionModelType {
    typealias Item = TantanganData
    
    init(original: SectionOfTantanganData, items: [TantanganData]) {
        self = original
        self.items = items
    }
}
