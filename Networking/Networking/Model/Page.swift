//
//  Page.swift
//  Networking
//
//  Created by Rahardyan Bisma on 28/12/18.
//  Copyright © 2018 PantauBersama. All rights reserved.
//

import Foundation

public protocol PageType {
    associatedtype T
    
    var item: T { get }
    var batch: Batch { get  }
}

public struct Page<Element>: PageType {
    public typealias T = Element
    
    public let item: Element
    public let batch: Batch
    
    public init(item: Element, batch: Batch) {
        self.item = item
        self.batch = batch
    }
}
