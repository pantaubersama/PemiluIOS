//
//  Paginate.swift
//  Networking
//
//  Created by alfian0 on 14/06/18.
//  Copyright © Extrainteger. All rights reserved.
//

import RxSwift

public extension ObservableType {
    public func paginate<O: ObservableType>(nextPageTrigger: O,
                                            hasNextPage: @escaping (E) -> Bool,
                                            nextPageFactory: @escaping (E) -> Observable<E>) -> Observable<E> {
        return flatMap { page -> Observable<E> in
            if !hasNextPage(page) {
                return Observable.just(page)
            }
            return Observable.concat(
                Observable.just(page),
                Observable.never().takeUntil(nextPageTrigger),
                nextPageFactory(page))
        }
    }
}
