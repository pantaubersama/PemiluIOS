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

enum CellModel {
    case live([Challenge])
    case standard(Challenge)
    case empty
}


struct SectionWordstadium {
    let title: String
    let descriptiom: String
    let type: LiniType
    let itemType: ProgressType
    var items: [CellModel]
    
    init(title: String,descriptiom: String,type: LiniType,itemType: ProgressType,items: [CellModel]) {
        self.title = title
        self.descriptiom = descriptiom
        self.type = type
        self.itemType = itemType
        self.items = items
    }
}

extension SectionWordstadium: SectionModelType {
    typealias Item = CellModel
    
    init(original: SectionWordstadium, items: [CellModel]) {
        self = original
        self.items = items
    }
}


