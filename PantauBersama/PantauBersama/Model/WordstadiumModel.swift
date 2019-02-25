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

struct SectionWordstadium {
    let title: String
    let descriptiom: String
    let type: LiniType
    let itemType: ProgressType
    var items: [Challenge]
    var itemsLive: [Challenge]
    
    init(title: String,descriptiom: String,type: LiniType,itemType: ProgressType,items: [Challenge], itemsLive: [Challenge]) {
        self.title = title
        self.descriptiom = descriptiom
        self.type = type
        self.itemType = itemType
        self.items = items
        self.itemsLive = itemsLive
    }
}

extension SectionWordstadium: SectionModelType {
    typealias Item = Challenge
    
    init(original: SectionWordstadium, items: [Challenge]) {
        self = original
        self.items = items
    }
}


