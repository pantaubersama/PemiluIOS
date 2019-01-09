//
//  CategoriesResponse.swift
//  Networking
//
//  Created by Hanif Sugiyanto on 08/01/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import Foundation

public struct CategoriesResponse: Codable {
    public var categories: [ClusterCategory]
    public var meta: Meta
}
