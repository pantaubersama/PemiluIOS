//
//  PenpolFilterCoordinator.swift
//  PantauBersama
//
//  Created by Rahardyan Bisma on 07/01/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import Foundation
import Common
import RxSwift
import RxCocoa

public enum FilterType {
    case question
    case quiz
    case pilpres
    case janji
}

class PenpolFilterCoordinator: BaseCoordinator<Void> {
    let navigationController: UINavigationController
    let filterType: FilterType
    let filterTrigger: AnyObserver<[PenpolFilterModel.FilterItem]>
    private var viewController: PenpolFilterController!
    private var viewModel: PenpolFilterViewModel!
    
    init(navigationController: UINavigationController, filterType: FilterType, filterTrigger: AnyObserver<[PenpolFilterModel.FilterItem]>) {
        self.navigationController = navigationController
        self.filterType = filterType
        self.filterTrigger = filterTrigger
    }
    
    override func start() -> Observable<Void> {
        if viewController == nil {
            viewController = PenpolFilterController()
        }
        
        viewModel = PenpolFilterViewModel(filterItems: generateFilterItems(), filterTrigger: filterTrigger)
        viewController.viewModel = viewModel
        
        viewController.hidesBottomBarWhenPushed = true
        
        navigationController.pushViewController(viewController, animated: true)
        
        return viewModel.output.apply
            .do(onNext: { [weak self](_) in
                self?.navigationController.popViewController(animated: true)
            })
            .asObservable()
    }
    
    private func generateFilterItems() -> [PenpolFilterModel] {
        switch filterType {
        case .question:
            return PenpolFilterModel.generateQuestionFilter()
        case .quiz:
            return []
        case .pilpres:
            return PenpolFilterModel.generatePilpresFilter()
        case .janji:
            return PenpolFilterModel.generateJanjiFilter()
        }
    }
}
