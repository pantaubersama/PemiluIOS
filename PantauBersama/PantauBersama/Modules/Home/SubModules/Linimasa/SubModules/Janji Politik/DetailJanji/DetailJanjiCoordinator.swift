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
}

class DetailJanjiCoordinator: BaseCoordinator<Void> {
    
    private let navigationController: UINavigationController!
    private let data: JanjiPolitik
    var finish: Observable<Void>!
    
    
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
        return Observable.never()
    }
    
}

extension DetailJanjiCoordinator: DetailJanjiNavigator {
    func shareJanji(data: Any) -> Observable<Void> {
        let activityViewController = UIActivityViewController(activityItems: ["content to be shared" as NSString], applicationActivities: nil)
        self.navigationController.present(activityViewController, animated: true, completion: nil)
        
        return Observable.never()
    }
    

}
