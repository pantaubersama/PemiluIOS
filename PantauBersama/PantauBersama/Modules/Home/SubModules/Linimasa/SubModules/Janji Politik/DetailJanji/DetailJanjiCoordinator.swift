//
//  DetailJanjiCoordinator.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 21/12/18.
//  Copyright © 2018 PantauBersama. All rights reserved.
//

import RxSwift
import RxCocoa
import Networking

protocol DetailJanjiNavigator {
    func shareJanji(data: Any) -> Observable<Void>
    func close()
}

class DetailJanjiCoordinator: BaseCoordinator<Void> {
    
    private let navigationController: UINavigationController!
    private let data: JanjiPolitik
    
    init(navigationController: UINavigationController, data: JanjiPolitik) {
        self.navigationController = navigationController
        self.data = data
    }
    
    override func start() -> Observable<Void> {
        let viewController = DetailJanjiController()
        let viewModel = DetailJanjiViewModel(navigator: self, data: data)
        viewController.viewModel = viewModel
        viewController.hidesBottomBarWhenPushed = true
        
        navigationController.pushViewController(viewController, animated: true)
        return viewModel.output.closeSelected.do(onNext: { [weak self](_) in
            self?.navigationController.popViewController(animated: true)
        }).asObservable()
    }
    
}

extension DetailJanjiCoordinator: DetailJanjiNavigator {
    func close() {
        guard let viewController = navigationController.viewControllers.first else {
            return
        }
        navigationController.popToViewController(viewController, animated: true)
    }
    
    func shareJanji(data: Any) -> Observable<Void> {
        let activityViewController = UIActivityViewController(activityItems: ["content to be shared" as NSString], applicationActivities: nil)
        self.navigationController.present(activityViewController, animated: true, completion: nil)
        
        return Observable.never()
    }
    

}
