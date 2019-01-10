//
//  CategoriesResponse.swift
//  Networking
//
//  Created by Hanif Sugiyanto on 08/01/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import Foundation

public protocol ICategories {
    var id: String { get }
    var name: String { get }
}


public struct CategoriesResponse: Codable {
    public var categories: [Category]
    public var meta: Meta
}

public struct SingleCategory: Codable {
    public var category: Category
}

public struct Category: Codable, ICategories {
    public var id: String
    public var name: String
}
