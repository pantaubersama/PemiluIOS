//
//  Facebook+Rx.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 13/01/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import Foundation
import RxSwift
import FBSDKCoreKit
import FBSDKLoginKit

public typealias MeFacebookResponse = (name: String?, email: String?, gender: String?, birthday: String?, photos: [String]?)


enum FacebookSDKError: Error {
    case tokenNotFound
}

public extension FBSDKLoginManager {
    // MARK: - Login Facebook
    public func loginFacebook(from: UIViewController?) -> Observable<FBSDKAccessToken> {
        return Observable.create({ [weak self] (observer: AnyObserver<FBSDKAccessToken>) in
            self?.logIn(withReadPermissions: ["public_profile", "email"], from: from, handler: { (result, error) in
                if let error = error {
                    observer.on(.error(error))
                    return
                }
                
                guard let token = result?.token else {
                    observer.on(.error(FacebookSDKError.tokenNotFound))
                    return
                }
                
                observer.on(.next(token))
                observer.on(.completed)
                
            })
            return Disposables.create()
        })
    }
    
    
    
}

public extension FBSDKGraphRequest {
   
    public func fetchMeFacebook() -> Observable<MeFacebookResponse> {
        return Observable.create { observer in
            let request = FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "name, email, gender, birthday, photos"])
            let task = request?.start { connection, result, error in
                if let error = error {
                    observer.on(.error(error))
                    return
                }
                
                guard let result = result as? [AnyHashable: Any] else {
                    observer.on(.error(FacebookSDKError.tokenNotFound))
                    return
                }
                
                let name = result["name"] as? String
                let email = result["email"] as? String
                let gender = result["gender"] as? String
                let birthday = result["birthday"] as? String
                let photos = result["photos"] as? [String]
                
                let response = MeFacebookResponse(name: name, email: email, gender: gender, birthday: birthday, photos: photos)
                observer.on(.next(response))
                observer.on(.completed)
            }
            
            return Disposables.create {
                task?.cancel()
            }
        }
    }
}
