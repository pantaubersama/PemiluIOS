//
//  NetworkService.swift
//  Networking
//
//  Created by Hanif Sugiyanto on 20/12/18.
//  Copyright © 2018 PantauBersama. All rights reserved.
//

import Moya
import RxSwift
import Common

public struct NetworkService {
    
    public static let instance = NetworkService()
    fileprivate let provider: MoyaProvider<MultiTarget>
    
    private init() {
        self.provider = MoyaProvider<MultiTarget>(
            plugins: [
                RequestLoadingPlugin()
            ]
        )
    }
    
}

public extension NetworkService {
    
    public func requestObject<T: TargetType, C: Decodable>(_ t: T, c: C.Type) -> Single<C> {
        return provider.rx.request(MultiTarget(t))
            .subscribeOn(ConcurrentDispatchQueueScheduler(qos: .background))
            .filterSuccessfulStatusAndRedirectCodes()
            .retryWhen({ (e) in
                Observable.zip(e, Observable.range(start: 1, count: 3), resultSelector: { $1 }).flatMap {
                        i in
                    return self.provider.rx.request(MultiTarget(PantauAuthAPI.refresh(type: .refreshToken)))
                        .asObservable()
                        .filterSuccessfulStatusAndRedirectCodes()
                        .map(IdentitasResponses.self)
                        .catchError({ (e) in
                            if case MoyaError.statusCode(let response) = e {
                                if response.statusCode == 401 {
                                    print("Your session is expired....")
                                }
                            }
                            return Observable.error(e)
                        })
                        .flatMapLatest({ (r) -> Observable<Void> in
                            let t = r.accessToken
                            let rt = r.refreshToken
                            let tt = r.tokenType
                            UserDefaults.Account.set(tt, forKey: .tokenType)
                            KeychainService.update(type: NetworkKeychainKind.refreshToken, data: rt)
                            KeychainService.update(type: NetworkKeychainKind.token, data: t)
                            return Observable.empty()
                        })
                }
            })
            .map(c.self)
            .catchError({ (error)  in
                guard let errorResponse = error as? MoyaError else { return Single.error(NetworkError.IncorrectDataReturned) }
                switch errorResponse {
                case .underlying(let (e, _)):
                    print(e.localizedDescription)
                    return Single.error(NetworkError(error: e as NSError))
                default:
                    let body = try
                        errorResponse.response?.map(ErrorResponse.self)
                    if let body = body {
                        print(body.error.errors)
                        return Single.error(NetworkError.SoftError(message: body.error.errors.first))
                    } else {
                        return Single.error(NetworkError.IncorrectDataReturned)
                    }
                }
            })
    }    
}
