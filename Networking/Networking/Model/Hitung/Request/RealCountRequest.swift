//
//  RealCountRequest.swift
//  Networking
//
//  Created by Nanang Rafsanjani on 20/03/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import Foundation

public struct RealCountRequest: Codable {
    public var tps: Int?
    public var provinceCode: Int?
    public var regencyCode: Int?
    public var districtCode: Int?
    public var villageCode: Int?
    public var latitude: Double?
    public var longitude: Double?
    
    public init() {
        
    }
}

public extension Encodable {
    public var dictionary: [String: Any]? {
        let enc = JSONEncoder()
        enc.keyEncodingStrategy = .convertToSnakeCase
        guard let data = try? enc.encode(self) else { return nil }
        return (try? JSONSerialization.jsonObject(with: data, options: .allowFragments)).flatMap { $0 as? [String: Any] }
    }
}
