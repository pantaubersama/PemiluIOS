//
//  Batch.swift
//  Networking
//
//  Created by Rahardyan Bisma on 28/12/18.
//  Copyright © 2018 PantauBersama. All rights reserved.
//

import Foundation

public struct Batch {
    public let offset: Int
    public let limit: Int
    public let total: Int
    public let count: Int
    public let page: Int
    
    public init(offset: Int, limit: Int, total: Int, count: Int, page: Int) {
        self.offset = offset
        self.limit = limit
        self.total = total
        self.count = count
        self.page = page
    }
}

public extension Batch {
    public var hasNextPage: Bool {
        return !(offset == total || offset + count == total)
    }
}

public extension Batch {
    public static var initial: Batch {
        return Batch(offset: 0, limit: 30, total: Int.max, count: Int.max, page: 1)
    }
    
    public func next() -> Batch {
        return Batch(offset: offset + count, limit: limit, total: total, count: count, page: page + 1)
    }
}
