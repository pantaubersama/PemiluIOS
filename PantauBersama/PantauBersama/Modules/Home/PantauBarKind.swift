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
//    case wordstadium
//    case lapor
    case merayakan
    
    var title: String? {
        switch self {
        case .linimasa:
            return "Menyerap"
        case .penpol:
            return "Menggali"
//        case .wordstadium:
//            return "Menguji"
        case .merayakan:
            return "Merayakan"
        }
    }
    
    var icon: UIImage? {
        switch self {
        case .linimasa:
            return #imageLiteral(resourceName: "icLinimasaInactive")
        case .penpol:
            return #imageLiteral(resourceName: "icPendidikanPolitikInactive")
//        case .wordstadium:
//            return #imageLiteral(resourceName: "icWordstadiumInactive")
        case .merayakan:
            return #imageLiteral(resourceName: "icHitungSuaraInactive")
        }
    }
    
    var iconSelected: UIImage? {
        switch self {
        case .linimasa:
            return #imageLiteral(resourceName: "icLinimasaActive")
        case .penpol:
            return #imageLiteral(resourceName: "icPendidikanPolitikActive")
//        case .wordstadium:
//            return #imageLiteral(resourceName: "icWordstadiumActive")
        case .merayakan:
            return #imageLiteral(resourceName: "icHitungSuaraActive")
        }
    }
    
    var navigationController: UINavigationController {
        let n = UINavigationController()
        n.tabBarItem.title = self.title
        n.tabBarItem.image = self.icon
        n.tabBarItem.selectedImage = self.iconSelected
        return n
    }
    
}
