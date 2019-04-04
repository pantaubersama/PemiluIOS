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
