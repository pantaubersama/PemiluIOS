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
    
    lazy var quizViewModel = QuizViewModel(navigator: viewModel.navigator, showTableHeader: true)
    lazy var askViewModel = QuestionListViewModel(navigator: viewModel.navigator, loadCreatedTrigger: viewModel.input.loadCreatedTrigger, showTableHeader: true)
    
    lazy var askController = QuestionController(viewModel: askViewModel)
    lazy var quisController = QuizController(viewModel: quizViewModel)
 
    override func viewDidLoad() {
        super.viewDidLoad()
        navbar.backgroundColor = Color.primary_red

        add(childViewController: askController, context: containerView)
        add(childViewController: quisController, context: containerView)
        
        navbar.notification.rx.tap
            .bind(to: viewModel.input.notifTrigger)
            .disposed(by: disposeBag)
        
        navbar.profile.rx.tap
            .bind(to: viewModel.input.profileTrigger)
            .disposed(by: disposeBag)
        
        navbar.note.rx.tap
            .bind(to: viewModel.input.catatanTrigger)
            .disposed(by: disposeBag)
        
        navbar.search.rx.tap
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
            .subscribe(onNext : { [unowned self] (i) in
                UIView.animate(withDuration: 0.3, animations: {
                    if i == 0 {
                        self.askController.view.alpha = 1.0
                        self.quisController.view.alpha = 0.0
                        self.createAskButton.isHidden = false
                    }else {
                        self.quisController.view.alpha = 1.0
                        self.quizViewModel.input.viewWillAppearTrigger.onNext(())
                        self.quizViewModel.input.loadQuizTrigger.onNext(())
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
        
        viewModel.output.userO
            .drive(onNext: { [weak self] (response) in
                guard let `self` = self else { return }
                let user = response.user
                if let thumbnail = user.avatar.thumbnail.url {
                    self.navbar.avatar.af_setImage(withURL: URL(string: thumbnail)!)
                }
            })
            .disposed(by: disposeBag)
        
        viewModel.output.profileSelected
            .drive()
            .disposed(by: disposeBag)
        
        viewModel.output.catatanSelected
            .drive()
            .disposed(by: disposeBag)
        
        viewModel.output.notifSelected
            .drive()
            .disposed(by: disposeBag)
        
        let left = UISwipeGestureRecognizer(target: self, action: #selector(swipeLeft))
        left.direction = .left
        self.view.addGestureRecognizer(left)
        
        let right = UISwipeGestureRecognizer(target: self, action: #selector(swipeRight))
        right.direction = .right
        self.view.addGestureRecognizer(right)
        
    }


    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
        viewModel.input.viewWillAppearTrigger.onNext(())
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = false
    }
    
    @objc func swipeLeft() {
        self.segmentedControl.swipeLeft()
        
    }
    
    @objc func swipeRight() {
        self.segmentedControl.swipeRight()
    }
}
