//
//  SectionOfProfileInfoData.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 25/12/18.
//  Copyright © 2018 PantauBersama. All rights reserved.
//

import Foundation
import RxDataSources

enum FieldType {
    case text
    case password
    case date
    case number
    case username
    case dropdown
}

struct ProfileInfoField {
    let key: String
    let value: String?
    let fieldType: FieldType
}

struct SectionOfProfileInfoData {
    let id: String
    var items: [Item]
    var header: ProfileHeaderItem
}

extension SectionOfProfileInfoData: SectionModelType {
    typealias Item = ProfileInfoField
    
    init(original: SectionOfProfileInfoData, items: [ProfileInfoField]) {
        self = original
        self.items = items
    }
}

