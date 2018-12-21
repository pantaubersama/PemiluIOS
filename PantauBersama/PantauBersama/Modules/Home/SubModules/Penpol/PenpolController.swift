//
//  PenpolController.swift
//  PantauBersama
//
//  Created by wisnu bhakti on 19/12/18.
//  Copyright © 2018 PantauBersama. All rights reserved.
//

import UIKit
import Common
import RxSwift

class PenpolController: UIViewController {
    @IBOutlet weak var segmentedControl: SegementedControl!
    @IBOutlet weak var containerView: UIView!
    
    var viewModel: PenpolViewModel!
    private let disposeBag = DisposeBag()
    
    lazy var quizViewModel = QuizViewModel(navigator: viewModel.navigator)
    
    private var askController = AskController()
    lazy var quisController = QuizController(viewModel: quizViewModel)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        add(childViewController: askController, context: containerView)
        add(childViewController: quisController, context: containerView)
        
        segmentedControl.rx.value
            .observeOn(MainScheduler.instance)
            .subscribe(onNext : { (i) in
                UIView.animate(withDuration: 0.3, animations: {
                    if i == 0 {
                        self.askController.view.alpha = 1.0
                        self.quisController.view.alpha = 0.0
                    }else {
                        self.quisController.view.alpha = 1.0
                        self.askController.view.alpha = 0.0
                    }
                })
            })
            .disposed(by: disposeBag)
    }



}
