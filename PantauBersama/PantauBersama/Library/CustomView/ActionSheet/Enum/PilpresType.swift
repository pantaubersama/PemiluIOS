//
//  PilpresType.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 19/12/18.
//  Copyright © 2018 PantauBersama. All rights reserved.
//
import UIKit

enum PilpresType: Int, CustomStringConvertible {
    
    case salin
    case bagikan
    case twitter
    
    var image: UIImage? {
        switch self {
        case .salin:
           return #imageLiteral(resourceName: "outlineLink24Px")
        case .bagikan:
            return #imageLiteral(resourceName: "outlineShare24Px")
        case .twitter:
            return #imageLiteral(resourceName: "twitter")
        }
    }
    
    var description: String {
        switch self {
        case .salin:
            return "Salin Tautan"
        case .bagikan:
            return "Bagikan"
        case .twitter:
            return "Buka di Aplikasi Twitter"
        }
    }
}
