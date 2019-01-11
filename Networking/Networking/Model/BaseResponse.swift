//
//  BaseResponse.swift
//  Networking
//
//  Created by Hanif Sugiyanto on 28/12/18.
//  Copyright © 2018 PantauBersama. All rights reserved.
//

import Foundation

public struct BaseResponse<T: Codable>: Codable {
    public var data: T
}

// use this one for type Array
public struct BaseResponses<T: Codable>: Codable {
    public var data: [T]
}
