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
    
    var viewModel: PenpolViewModel!
    private let disposeBag = DisposeBag()
    
    lazy var quizViewModel = QuizViewModel(navigator: viewModel.navigator)
    lazy var askViewModel = AskViewModel(navigator: viewModel.navigator)
    
    lazy var askController = AskController(viewModel: askViewModel)
    lazy var quisController = QuizController(viewModel: quizViewModel)
    
    private lazy var searchBar: UISearchBar = {
        let search = UISearchBar()
        search.searchBarStyle = .minimal
        search.sizeToFit()
        return search
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        add(childViewController: askController, context: containerView)
        add(childViewController: quisController, context: containerView)
        
        let notifications = UIBarButtonItem(image: #imageLiteral(resourceName: "icNotif"), style: .plain, target: nil, action: nil)
        let profile = UIBarButtonItem(image: #imageLiteral(resourceName: "icDummyPerson"), style: .plain, target: nil, action: nil)
        navigationItem.leftBarButtonItem = profile
        navigationItem.rightBarButtonItem = notifications
        navigationItem.titleView = searchBar
        
        createAskButton.rx.tap
            .bind(to: viewModel.input.addTrigger)
            .disposed(by: disposeBag)
        
        filterButton.rx.tap
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
        
    }


    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = false
        self.navigationController?.navigationBar.configure(type: .kuis)
    }
}