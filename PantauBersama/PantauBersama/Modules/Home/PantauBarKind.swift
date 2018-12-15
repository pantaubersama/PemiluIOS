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
    case vote
    
    var title: String? {
        switch self {
        case .linimasa:
            return "Linimasa"
        case .penpol:
            return "Penpol"
        case .wordstadium:
            return "Wordstadium"
        case .lapor:
            return "Lapor"
        case .vote:
            return "Vote"
        }
    }
    
    var icon: UIImage? {
        switch self {
        case .linimasa:
           return #imageLiteral(resourceName: "icViewListOff")
        default:
            return #imageLiteral(resourceName: "icViewListOff")
        }
    }
    
    
    var navigationController: UINavigationController {
        let n = UINavigationController()
        n.tabBarItem.title = self.title
        n.tabBarItem.image = self.icon
        return n
    }
    
}
