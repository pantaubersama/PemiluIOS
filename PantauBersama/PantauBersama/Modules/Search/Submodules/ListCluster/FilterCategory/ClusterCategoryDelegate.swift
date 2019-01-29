//
//  File.swift
//  PantauBersama
//
//  Created by Rahardyan Bisma on 27/01/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import Foundation
import RxSwift
import Networking

protocol ClusterCategoryDelegate {
    func didSelectCategory(item: ICategories) -> Observable<Void>
}
