//
//  ClusterType.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 06/01/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import Foundation
import Networking

enum ClusterType {
    case `default`
    case lihat(data: User?)
    case undang(data: User?)
    case leave
}

enum ClusterOption {
    case cancel
    case done
}
