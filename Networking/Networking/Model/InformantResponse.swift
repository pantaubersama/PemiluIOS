//
//  InformantResponse.swift
//  Networking
//
//  Created by Hanif Sugiyanto on 31/12/18.
//  Copyright © 2018 PantauBersama. All rights reserved.
//

import Foundation

public struct InformantResponse: Codable {
    
    public var informant: Informant
    
}

public struct Informant: Codable {
    
    public let id: String
    public var identity: String?
    public var pob: String?
    public var dob: String
    public var gender: Int?
    public var genderString: String?
    public var occupation: String?
    public var nationality: String?
    public var address: String?
    public var phone: String?
    
    private enum CodingKeys: String, CodingKey {
        case id = "user_id"
        case identity = "identity_number"
        case pob, dob, gender, occupation, nationality, address
        case genderString = "gender_str"
        case phone = "phone_number"
    }
}
