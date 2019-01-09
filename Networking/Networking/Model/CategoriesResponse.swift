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

public struct SingleCategory: Codable {
    public var category: Category
}

public struct Category: Codable {
    public var id: String
    public var name: String
}
