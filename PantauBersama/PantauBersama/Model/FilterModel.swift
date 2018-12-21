//
//  FilterModel.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 21/12/18.
//  Copyright © 2018 PantauBersama. All rights reserved.
//

import Foundation
import Networking
import RxDataSources


struct FilterField {
    let key: String
    let value: Int
}

struct SectionOfFilterData {
    var items: [Item]
}

extension SectionOfFilterData: SectionModelType {
    typealias Item = FilterField
    
    init(original: SectionOfFilterData, items: [FilterField]) {
        self = original
        self.items = items
    }
}
