//
//  File.swift
//  PantauBersama
//
//  Created by Rahardyan Bisma on 27/01/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import Foundation
import RxSwift

protocol ClusterCategoryDelegate {
    func didSelectCategory(item: ICategories, index: IndexPath) -> Observable<Void>
}
