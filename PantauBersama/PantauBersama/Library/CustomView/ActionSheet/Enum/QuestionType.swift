//
//  AskType.swift
//  PantauBersama
//
//  Created by wisnu bhakti on 26/12/18.
//  Copyright © 2018 PantauBersama. All rights reserved.
//

import UIKit
import Networking

enum QuestionType {
    case hapus(question: QuestionModel)
    case salin(question: QuestionModel)
    case bagikan(question: QuestionModel)
    case laporkan(question: QuestionModel)
}

enum QuestionSingleType {
    case hapus(question: Question)
    case salin(question: Question)
    case bagikan(question: Question)
    case laporkan(question: Question)
}
