//
//  String+Copy.swift
//  Networking
//
//  Created by Rahardyan Bisma on 01/01/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import Foundation

extension String {
    public func copyToClipboard() {
        UIPasteboard.general.string = self
    }
}
