//
//  ChallengeDetailType.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 07/03/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import UIKit
import Networking

enum ChallengeDetailType {
    
    case hapus(id: String)
    case salin(data: Challenge)
    case share(data: Challenge)
    
    var image: UIImage? {
        switch self {
        case .hapus:
            return #imageLiteral(resourceName: "icDelete")
        case .salin:
            return #imageLiteral(resourceName: "outlineLink24Px")
        case .share:
            return #imageLiteral(resourceName: "outlineShare24Px")
        }
    }
    
    var description: String {
        switch self {
        case .hapus:
            return "Hapus"
        case .salin:
            return "Salin Tautan"
        case .share:
            return "Bagikan"
        }
    }
    
}
