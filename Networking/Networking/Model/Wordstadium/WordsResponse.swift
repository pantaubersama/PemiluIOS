//
//  WordsResponse.swift
//  Networking
//
//  Created by Rahardyan Bisma Setya Putra on 06/03/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import Foundation

public struct WordsResponse: Codable {
    public let meta: Meta
    public let words: [Word]
}
