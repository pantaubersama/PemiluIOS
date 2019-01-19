//
//  JanjiType.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 21/12/18.
//  Copyright © 2018 PantauBersama. All rights reserved.
//

import UIKit
import Networking

enum JanjiType {
    
    case hapus(id: String)
    case salin(data: JanjiPolitik)
    case bagikan(data: JanjiPolitik)
    case laporkan(data: JanjiPolitik)
    
    var image: UIImage? {
        switch self {
        case .hapus:
             return #imageLiteral(resourceName: "icDelete")
        case .salin:
            return #imageLiteral(resourceName: "outlineLink24Px")
        case .bagikan:
            return #imageLiteral(resourceName: "outlineShare24Px")
        case .laporkan:
            return #imageLiteral(resourceName: "icLapor")
        }
    }
    
    var description: String {
        switch self {
        case .hapus:
            return "Hapus"
        case .salin:
            return "Salin Tautan"
        case .bagikan:
            return "Bagikan"
        case .laporkan:
            return "Laporkan"
        }
    }
}
