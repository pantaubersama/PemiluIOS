//
//  Twitter+Rx.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 12/01/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import Foundation
import RxSwift
import TwitterKit

private enum TwitterError: Error {
    case unknown
}

public extension TWTRTwitter {
    
    
    // MARK: - Login twitter
    // Parameter client: API Client used to laod the request
    public func rx_loginTwitter(client: TWTRAPIClient) -> Observable<TWTRSession> {
        return Observable.create({ (observer: AnyObserver<TWTRSession>) -> Disposable in
            self.logIn(completion: { (session, error) in
                guard let session = session else {
                    observer.onError(error ?? TwitterError.unknown)
                    return
                }
                observer.onNext(session)
                observer.onCompleted()
            })
            return Disposables.create()
        })
    }
    
    // MARK: - Loads twitter user
    // parameter userID and client used to load the request
    public func rx_loadUserWithIDTwitter(userID: String, client: TWTRAPIClient) -> Observable<TWTRUser> {
        return Observable.create({ (observer: AnyObserver<TWTRUser>) -> Disposable in
            client.loadUser(withID: userID, completion: { (user, error) in
                guard let user = user else {
                    observer.onError(error ?? TwitterError.unknown)
                    return
                }
                observer.onNext(user)
                observer.onCompleted()
            })
            return Disposables.create()
        })
    }
    
    // MARK
    // Login using Twitter
    public func loginTwitter() -> Observable<TWTRSession> {
        return Observable.create({ [weak self] (observer: AnyObserver<TWTRSession>) -> Disposable in
            self?.logIn(completion: { (session, error) in
                guard let session = session else {
                    observer.onError(error ?? TwitterError.unknown)
                    return
                }
                observer.onNext(session)
                observer.onCompleted()
            })
            return Disposables.create()
        })
    }
}
