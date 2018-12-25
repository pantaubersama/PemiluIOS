//
//  SectionOfProfileEditData.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 25/12/18.
//  Copyright © 2018 PantauBersama. All rights reserved.
//

import Foundation
import RxDataSources
import Common

struct SectionOfProfileEditData {
    var items: [Item]
}

extension SectionOfProfileEditData: SectionModelType {
    typealias Item = ICellConfigurator
    
    init(original: SectionOfProfileEditData, items: [ICellConfigurator]) {
        self = original
        self.items = items
    }
}
