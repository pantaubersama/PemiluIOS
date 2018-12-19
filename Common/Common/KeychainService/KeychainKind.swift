//
//  KeychainKind.swift
//  Common
//
//  Created by Hanif Sugiyanto on 20/12/18.
//  Copyright © 2018 PantauBersama. All rights reserved.
//

public protocol KeychainKind  {
    var service: String { get }
    var account: String { get }
}
