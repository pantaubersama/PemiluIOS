//
//  PilpresType.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 19/12/18.
//  Copyright © 2018 PantauBersama. All rights reserved.
//
import UIKit
import Networking

enum PilpresType {
    
    case salin(data: Feeds)
    case bagikan(data: Feeds)
    case twitter(data: Feeds)
    
}
