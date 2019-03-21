//
//  WordstadiumType.swift
//  PantauBersama
//
//  Created by wisnu bhakti on 22/02/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import UIKit
import Networking

enum WordstadiumType {
    
    case salin(data: Challenge)
    case bagikan(data: Challenge)
    
    var image: UIImage? {
        switch self {
        case .salin:
            return #imageLiteral(resourceName: "outlineLink24Px")
        case .bagikan:
            return #imageLiteral(resourceName: "outlineShare24Px")
        }
    }
    
    var description: String {
        switch self {
        case .salin:
            return "Salin Tautan"
        case .bagikan:
            return "Bagikan"
        }
    }
}
