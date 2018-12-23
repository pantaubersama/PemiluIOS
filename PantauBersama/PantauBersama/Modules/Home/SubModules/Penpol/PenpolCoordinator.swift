//
//  PenpolCoordinator.swift
//  PantauBersama
//
//  Created by wisnu bhakti on 19/12/18.
//  Copyright © 2018 PantauBersama. All rights reserved.
//

import Foundation
import RxSwift
import Common

protocol PenpolNavigator: QuizNavigator {
    func launchFilter() -> Observable<Void>
    func launchCreateQuestion() -> Observable<Void>
}

class PenpolCoordinator: BaseCoordinator<Void> {
    
    private let navigationController: UINavigationController!
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    override func start() -> Observable<CoordinationResult> {
        let viewController = PenpolController()
        let viewModel = PenpolViewModel(navigator: self)
        viewController.viewModel = viewModel
        navigationController.setViewControllers([viewController], animated: true)
        return Observable.never()
    }
}

extension PenpolCoordinator: PenpolNavigator {
    func launchFilter() -> Observable<Void> {
        let filterCoordinator = FilterCoordinator(navigationController: self.navigationController)
        return coordinate(to: filterCoordinator)
    }
    
    func launchCreateQuestion() -> Observable<Void> {
        // TODO: change filter to create question coordinator
        let filterCoordinator = FilterCoordinator(navigationController: self.navigationController)
        return coordinate(to: filterCoordinator)
    }
    
    func openQuiz(quiz: Any) -> Observable<Void> {
        let quizDetailCoordinator = QuizDetailCoordinator(navigationController: self.navigationController, quizModel: quiz)
        return coordinate(to: quizDetailCoordinator)
    }
    
    func shareQuiz(quiz: Any) -> Observable<Void> {
        // TODO: coordinate to share
        let quizDetailCoordinator = QuizDetailCoordinator(navigationController: self.navigationController, quizModel: quiz)
        return coordinate(to: quizDetailCoordinator)
    }
    
    func openInfoQuiz() -> Observable<Void> {
        let quizInfoCoordinator = QuizInfoCoordinator(navigationController: self.navigationController)
        return coordinate(to: quizInfoCoordinator)
    }
}
