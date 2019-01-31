//
//  Gender.swift
//  Networking
//
//  Created by Hanif Sugiyanto on 31/12/18.
//  Copyright © 2018 PantauBersama. All rights reserved.
//

import Foundation

public enum Gender: String, Codable {
    case female = "Perempuan"
    case male = "Laki-laki"
    case unknown
    
    public var title: String? {
        switch self {
        case .female:
            return "Perempuan"
        case .male:
            return "Laki-laki"
        default:
            return nil
        }
    }
    
    public static func type(title: String?) -> Gender {
        guard let title = title else { return .unknown }
        switch title {
        case "Perempuan":
            return .female
        case "Laki-laki":
            return .male
        default:
            return .unknown
        }
    }
    
    public static func index(title: String?) -> Int {
        guard let title = title else { return 2 }
        switch title {
        case "Perempuan":
            return 0
        case "Laki-laki":
            return 1
        default:
            return 2
        }
    }
}
