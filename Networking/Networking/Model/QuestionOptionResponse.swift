//
//  QuestionReportResponse.swift
//  Networking
//
//  Created by Rahardyan Bisma on 01/01/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import Foundation

public struct QuestionOptionResponse: Codable {
    public let data: DataClass
}

public struct DataClass: Codable {
    public let vote: Vote
}

public struct Vote: Codable {
    public let status: Bool
    public let text: String
}
