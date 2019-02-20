//
//  WordstadiumListCoordinator.swift
//  PantauBersama
//
//  Created by wisnu bhakti on 15/02/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import RxSwift


protocol WordstadiumListNavigator {
    var finish: Observable<Void>! { get set }
}


final class WordstadiumListCoordinator: BaseCoordinator<Void> {
    
    private let navigationController: UINavigationController
    private let wordstadium: SectionWordstadium
    var finish: Observable<Void>!
    
    init(navigationController: UINavigationController, wordstadium: SectionWordstadium) {
        self.navigationController = navigationController
        self.wordstadium = wordstadium
    }
    
    override func start() -> Observable<Void> {
        let viewModel = WordstadiumListViewModel(navigator: self, wordstadium: self.wordstadium)
        let viewController = WordstadiumListViewController()
        viewController.viewModel = viewModel
        viewController.hidesBottomBarWhenPushed = true
        navigationController.pushViewController(viewController, animated: true)
        return finish.do(onNext: { [weak self] (_) in
            self?.navigationController.popViewController(animated: true)
        })
    }
    
}

extension WordstadiumListCoordinator: WordstadiumListNavigator {

}
