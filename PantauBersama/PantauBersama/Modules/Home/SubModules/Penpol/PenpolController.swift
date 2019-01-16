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
    @IBOutlet weak var createAskButton: UIButton!
    @IBOutlet weak var filterButton: UIButton!
    @IBOutlet weak var navbar: Navbar!
    
    var viewModel: PenpolViewModel!
    private let disposeBag = DisposeBag()
    
//<<<<<<< HEAD
//    lazy var quizViewModel = QuizViewModel(navigator: viewModel.navigator, showTableHeader: true)
//    lazy var askViewModel = QuestionViewModel(navigator: viewModel.navigator, showTableHeader: true)
//=======
    lazy var quizViewModel = QuizViewModel(navigator: viewModel.navigator, showTableHeader: true)
    lazy var askViewModel = QuestionListViewModel(navigator: viewModel.navigator, showTableHeader: true)
//>>>>>>> [Bhakti][Refactor] Refactor tanya kandidat
    
    lazy var askController = QuestionController(viewModel: askViewModel)
    lazy var quisController = QuizController(viewModel: quizViewModel)
 
    override func viewDidLoad() {
        super.viewDidLoad()

        add(childViewController: askController, context: containerView)
        add(childViewController: quisController, context: containerView)
        
        navbar.search.rx.textDidBeginEditing
            .do(onNext: { [unowned self](_) in
                self.navbar.search.endEditing(true)
            })
            .bind(to: viewModel.input.searchTrigger)
            .disposed(by: disposeBag)
        
        createAskButton.rx.tap
            .bind(to: viewModel.input.addTrigger)
            .disposed(by: disposeBag)
        
        filterButton.rx.tap
            .map { [unowned self](_) -> (type: FilterType, filterTrigger: AnyObserver<[PenpolFilterModel.FilterItem]>) in
                return self.askController.view.alpha == 1.0 ? (type: .question, filterTrigger: self.askViewModel.input.filterI) : (type: .quiz, filterTrigger: self.quizViewModel.input.filterTrigger)
            }
            .bind(to: viewModel.input.filterTrigger)
            .disposed(by: disposeBag)
        
        segmentedControl.rx.value
            .observeOn(MainScheduler.instance)
            .subscribe(onNext : { (i) in
                UIView.animate(withDuration: 0.3, animations: {
                    if i == 0 {
                        self.askController.view.alpha = 1.0
                        self.quisController.view.alpha = 0.0
                        self.createAskButton.isHidden = false
                    }else {
                        self.quisController.view.alpha = 1.0
                        self.askController.view.alpha = 0.0
                        self.createAskButton.isHidden = true
                    }
                })
            })
            .disposed(by: disposeBag)
        
        
        viewModel.output.addSelected
            .drive()
            .disposed(by: disposeBag)
        
        viewModel.output.filterSelected
            .drive()
            .disposed(by: disposeBag)
        
        viewModel.output.searchSelected
            .drive()
            .disposed(by: disposeBag)
        
    }


    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = false
    }
}
