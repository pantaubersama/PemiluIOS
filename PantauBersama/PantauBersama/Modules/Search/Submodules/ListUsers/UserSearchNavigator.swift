//
//  UserSearchNavigator.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 24/01/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import RxSwift

protocol UserSearchNavigator {
    func launchProfileUser(isMyAccount: Bool, userId: String?) -> Observable<Void>
}
