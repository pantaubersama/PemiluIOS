//
//  WordstadiumModel.swift
//  PantauBersama
//
//  Created by wisnu bhakti on 14/02/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//
import Foundation
import RxDataSources
import Networking

enum ItemType {
    case live
    case inProgress
    case comingsoon
    case done
    case challenge
    case privateComingsoon
    case privateDone
    case privateChallenge
}

struct Wordstadium {
    let title: String
    
    init(title: String) {
        self.title = title
    }
}

struct SectionWordstadium {
    let title: String
    let descriptiom: String
    let itemType: ItemType
    var items: [Wordstadium]
    var itemsLive: [Wordstadium]
    
    init(title: String,descriptiom: String,itemType: ItemType,items: [Wordstadium], itemsLive: [Wordstadium]) {
        self.title = title
        self.descriptiom = descriptiom
        self.itemType = itemType
        self.items = items
        self.itemsLive = itemsLive
    }
}


extension SectionWordstadium: SectionModelType {
    typealias Item = Wordstadium

    init(original: SectionWordstadium, items: [Wordstadium]) {
        self = original
        self.items = items
    }
}
