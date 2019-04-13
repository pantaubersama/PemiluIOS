//
//  SectionModelDPR.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 29/03/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import Foundation
import Networking
import RxDataSources


struct CandidateActor {
    var id: Int
    var name: String
    var value: Int
    var number: Int
    
    init(id: Int, name: String, value: Int, number: Int) {
        self.id = id
        self.name = name
        self.value = value
        self.number = number
    }
}

struct SectionModelDPR {
    var header: String
    var number: Int
    var logo: String
    var items: [Item]
}

extension SectionModelDPR: SectionModelType {
    typealias Item = CandidateActor
    
    init(original: SectionModelDPR, items: [CandidateActor]) {
        self = original
        self.items = items
    }
}

///  Section Model for calculations
struct SectionModelCalculations {
    var header: String
    var headerCount: Int
    var headerNumber: Int
    var headerLogo: String
    var items: [Item]
    var footerCount: Int
    
    init(header: String, headerCount: Int, headerNumber: Int, headerLogo: String, items: [Item], footerCount: Int) {
        self.header = header
        self.headerCount = headerCount
        self.headerNumber = headerNumber
        self.headerLogo = headerLogo
        self.items = items
        self.footerCount = footerCount
    }
}

extension SectionModelCalculations: SectionModelType {
    typealias Item = CandidateActor
    
    init(original: SectionModelCalculations, items: [CandidateActor]) {
        self = original
        self.items = items
    }
    
}
