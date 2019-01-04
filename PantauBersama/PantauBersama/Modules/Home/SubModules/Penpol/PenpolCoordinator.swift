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

protocol PenpolNavigator: QuizNavigator, QuestionNavigator {
    func launchFilter() -> Observable<Void>
    func openInfoPenpol(infoType: PenpolInfoType) -> Observable<Void>
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
    
    func launchCreateAsk() -> Observable<Void> {
        let createAskCoordinator = CreateAskCoordinator(navigationController: self.navigationController)
        return coordinate(to: createAskCoordinator)
    }
    
    func shareQuestion(question: String) -> Observable<Void> {
        // TODO: coordinate to share
        let activityViewController = UIActivityViewController(activityItems: [question as NSString], applicationActivities: nil)
        self.navigationController.present(activityViewController, animated: true, completion: nil)
        
        return Observable.never()
    }
    
    func openQuiz(quiz: Any) -> Observable<Void> {
        let quizDetailCoordinator = QuizDetailCoordinator(navigationController: self.navigationController, quizModel: quiz)
        return coordinate(to: quizDetailCoordinator)
    }
    
    func shareQuiz(quiz: Any) -> Observable<Void> {
        // TODO: coordinate to share
        let activityViewController = UIActivityViewController(activityItems: ["content to be shared" as NSString], applicationActivities: nil)
        self.navigationController.present(activityViewController, animated: true, completion: nil)
        
        return Observable.never()
    }
    
    func shareTrend(trend: Any) -> Observable<Void> {
        // TODO: coordinate to share
        let activityViewController = UIActivityViewController(activityItems: ["content to be shared" as NSString], applicationActivities: nil)
        self.navigationController.present(activityViewController, animated: true, completion: nil)
        
        return Observable.never()
    }
    
    func openInfoPenpol(infoType: PenpolInfoType) -> Observable<Void> {
        let penpolInfoCoordinator = PenpolInfoCoordinator(navigationController: self.navigationController, infoType: infoType)
        return coordinate(to: penpolInfoCoordinator)
    }
}
