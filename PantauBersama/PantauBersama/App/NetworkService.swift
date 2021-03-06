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
import Networking

public struct NetworkService {
    
    public static var instance = NetworkService()
    var provider: MoyaProvider<MultiTarget>
    
    public init() {
        self.provider = MoyaProvider<MultiTarget>(
            plugins: [
                RequestLoadingPlugin()
            ]
        )
    }
    
}

public extension NetworkService {
    
    // MARK:- Request Objet
    // This Function will have two function
    // first for request nd checking access token if 401 or not
    // second for thrown into identitias auth if there's another error from refresh token / token is missing
    // return Single<> will call last request with generated new token from 401
    
    public func requestObject<T: TargetType, C: Decodable>(_ t: T, c: C.Type) -> Single<C> {
        print("base url \(t.baseURL)\(t.path) \(t.headers)")
        return self.provider.rx.request(MultiTarget(t))
            .subscribeOn(ConcurrentDispatchQueueScheduler(qos: .background))
            .filterSuccessfulStatusAndRedirectCodes()
            .do(onSuccess: { (response) in
                let json = try? JSONSerialization.jsonObject(with: response.data, options: JSONSerialization.ReadingOptions.allowFragments) as? [String: Any]
                print("json response \(json)")
            })
            .do(onError: { (e) in
                if case MoyaError.statusCode(let response) = e  {
                    // here will check if token 401
                    // will retry to refresh token
                    let json = try? JSONSerialization.jsonObject(with: response.data, options: JSONSerialization.ReadingOptions.allowFragments) as? [String: Any]
                    print("json response \(json)")
                    print("STATUS CODE: \(response.statusCode)")
                }
            })
            .retryWhen({ (error: Observable<Error>) -> Observable<PantauRefreshResponse> in
                return error.enumerated().flatMap { (index, error) -> Observable<PantauRefreshResponse> in
                    guard let moyaError = error as? MoyaError, let response = moyaError.response, index <= 3  else {
                        throw error
                    }
                    
                    if response.statusCode == 401 {
                        // Reffresh token
                        return self.provider.rx.request(MultiTarget(PantauAuthAPI.refresh(type: .refreshToken)))
                            .asObservable()
                            .filterSuccessfulStatusAndRedirectCodes()
                            .map(PantauRefreshResponse.self)
                            .catchError({ (e) in
                                print("baseUrl error login \(t.baseURL)\(t.path) \(t.headers)")
                                print("error \(e.localizedDescription)")
                                if case MoyaError.statusCode(let response) = e {
                                    print("Status response: ... \(response.statusCode)")
                                    if response.statusCode == 401 {
                                        print("Your session is expired....")
                                        let alert = UIAlertController(title: "Perhatian", message: "Sesi Anda telah berakhir, silahkan login terlebih dahulu", preferredStyle: .alert)
                                        alert.addAction(UIAlertAction(title: "Login", style: .destructive, handler: { (_) in
                                            KeychainService.remove(type: NetworkKeychainKind.token)
                                            KeychainService.remove(type: NetworkKeychainKind.refreshToken)
                                            // need improve this later
                                            // todo using wkwbview or using another framework to handle auth
                                            var appCoordinator: AppCoordinator!
                                            let disposeBag = DisposeBag()
                                            var window: UIWindow?
                                            window = UIWindow()
                                            appCoordinator = AppCoordinator(window: window!)
                                            appCoordinator.start()
                                                .subscribe()
                                                .disposed(by: disposeBag)
                                            
                                        }))
                                        alert.show()
                                    }
                                }
                                return Observable.error(e)
                            })
                            .flatMapLatest({ (r) -> Observable<PantauRefreshResponse> in
                                let t = r.accessToken
                                let rt = r.refreshToken
                                let tt = r.tokenType
                                UserDefaults.Account.set(tt, forKey: .tokenType)
                                KeychainService.update(type: NetworkKeychainKind.refreshToken, data: rt)
                                KeychainService.update(type: NetworkKeychainKind.token, data: t)
                                return Observable.just(r) // This function will refresh last request with new access token
                            })
                    } else {
                        return Observable.error(error)
                    }

                }
            })
            .map(c.self)
            .catchError({ (error)  in
                guard let errorResponse = error as? MoyaError else { return Single.error(NetworkError.IncorrectDataReturned) }
                switch errorResponse {
                case .underlying(let (e, _)):
                    print(e.localizedDescription)
//                    return Single.error(NetworkError(error: e as NSError))
                    return Single.error(e)
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
