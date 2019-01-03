//
//  WebCoordinator.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 02/01/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import RxSwift


protocol WebNavigator {
    func back()
    func launchCoordinator() -> Observable<Void>
}

final class WebCoordinator: BaseCoordinator<Void> {
    
    
    private let window: UIWindow
    private let url: String
    private let navigationController: UINavigationController
    private var appCoordinator: AppCoordinator!
    
    init(window: UIWindow, url: String) {
        self.window = window
        self.url = url
        self.navigationController = UINavigationController()
    }
    
    override func start() -> Observable<Void> {
        let viewModel = WebViewModel(navigator: self, url: url)
        let viewController = WebController()
        viewController.viewModel = viewModel
        navigationController.viewControllers = [viewController]
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
        return Observable.empty()
    }
    
}

extension WebCoordinator: WebNavigator {
    
    func back() {
        appCoordinator = AppCoordinator(window: self.window)
        appCoordinator.start()
            .subscribe()
            .disposed(by: disposeBag)
    }
    
    func launchCoordinator() -> Observable<Void> {
        // MARK
        // State when user first install, will coordinate into
        // start setting configurateion (i.e : Buat Profil)
        let buatProfilCoordinator = BuatProfileCoordinator(window: self.window)
        return self.coordinate(to: buatProfilCoordinator)
    }
}
