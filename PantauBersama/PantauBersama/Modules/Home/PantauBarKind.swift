//
//  PantauBarKind.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 15/12/18.
//  Copyright © 2018 PantauBersama. All rights reserved.
//

import UIKit

enum PantauBarKind: Int {
    case linimasa
    case penpol // pendidikan politik
    case wordstadium
    case lapor
    case rekap
    
    var title: String? {
        switch self {
        case .linimasa:
            return "Linimasa"
        case .penpol:
            return "Pendidikan Politik"
        case .wordstadium:
            return "Wordstadium"
        case .lapor:
            return "Lapor"
        case .rekap:
            return "Rekap"
        }
    }
    
    var icon: UIImage? {
        switch self {
        case .linimasa:
            return #imageLiteral(resourceName: "icLinimasaInactive")
        case .penpol:
            return #imageLiteral(resourceName: "icPendidikanPolitikInactive")
        case .wordstadium:
            return #imageLiteral(resourceName: "icWordstadiumInactive")
        case .lapor:
            return #imageLiteral(resourceName: "icLaporInactive")
        case .rekap:
            return #imageLiteral(resourceName: "icHitungSuaraInactive")
        }
    }
    
    var iconSelected: UIImage? {
        switch self {
        case .linimasa:
            return #imageLiteral(resourceName: "icLinimasaActive")
        case .penpol:
            return #imageLiteral(resourceName: "icPendidikanPolitikActive")
        case .wordstadium:
            return #imageLiteral(resourceName: "icWordstadiumActive")
        case .lapor:
            return #imageLiteral(resourceName: "icLaporActive")
        case .rekap:
            return #imageLiteral(resourceName: "icHitungSuaraActive")
        }
    }
    
    var navigationController: UINavigationController {
        let n = UINavigationController()
//        n.tabBarItem.title = self.title
        n.tabBarItem.image = self.icon
        n.tabBarItem.selectedImage = self.iconSelected
        return n
    }
    
}
