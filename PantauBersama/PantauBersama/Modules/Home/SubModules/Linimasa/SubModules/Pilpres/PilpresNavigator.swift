//
//  PilpresNavigator.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 26/12/18.
//  Copyright © 2018 PantauBersama. All rights reserved.
//

import Foundation
import RxSwift

protocol PilpresNavigator {
    func sharePilpres(data: Any) -> Observable<Void>
    func openTwitter(data: String) -> Observable<Void>
}
