//
//  LinimasaController.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 15/12/18.
//  Copyright © 2018 PantauBersama. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Common

class LinimasaController: UIViewController {
    
    @IBOutlet weak var filter: UIButton!
    @IBOutlet weak var addJanji: UIButton!
    @IBOutlet weak var segementedControl: SegementedControl!
    @IBOutlet weak var container: UIView!
    
    var viewModel: LinimasaViewModel!
    
    private lazy var pilpresController = PilpresViewController()
    private lazy var janjiController = JanjiPolitikViewController()
    
    private lazy var searchBar: UISearchBar = {
       let search = UISearchBar()
        search.searchBarStyle = .minimal
        search.sizeToFit()
        return search
    }()
    
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        add(childViewController: pilpresController, context: container)
        add(childViewController: janjiController, context: container)
        
        let notifications = UIBarButtonItem(image: #imageLiteral(resourceName: "icNotif"), style: .plain, target: nil, action: nil)
        let profile = UIBarButtonItem(image: #imageLiteral(resourceName: "icDummyPerson"), style: .plain, target: nil, action: nil)
        navigationItem.leftBarButtonItem = profile
        navigationItem.rightBarButtonItem = notifications
        navigationItem.titleView = searchBar
        
        
        // MARK
        // bind to viewModel
        filter.rx.tap
            .bind(to: viewModel.input.filterTrigger)
            .disposed(by: disposeBag)
        
        addJanji.rx.tap
            .bind(to: viewModel.input.addTrigger)
            .disposed(by: disposeBag)
        
        viewModel.output.filterSelected
            .drive()
            .disposed(by: disposeBag)
        
        // MARK
        // segmented control value
        // assign extension Reactive UIControl
        segementedControl.rx.value
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [unowned self] i in
                UIView.animate(withDuration: 0.3, animations: {
                    if i == 0 {
                        self.pilpresController.view.alpha = 1.0
                        self.janjiController.view.alpha = 0.0
                    } else {
                        self.pilpresController.view.alpha = 0.0
                        self.janjiController.view.alpha = 1.0
                    }
                })
            })
            .disposed(by: disposeBag)
        
        // MARK
        // Navigation bar hide
        // when scrolling tableViews
        let tableViews = [self.pilpresController.tableView,
                          self.janjiController.tableView]
        tableViews.forEach { tableView in
            guard let tableView = tableView else { return }
            tableView.scrollsToTop = true
            Driver.merge([
                pilpresController.tableView.rx.contentOffset.asDriver(),
                janjiController.tableView.rx.contentOffset.asDriver()
                ])
                .drive(onNext: { position in
                    UIView.animate(withDuration: 0.3, animations: {
                        if position.y >= 153.0 {
                            self.navigationController?.isNavigationBarHidden = true
                        } else {
                            self.navigationController?.isNavigationBarHidden = false
                        }
                    })
                })
                .disposed(by: disposeBag)
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.configure(type: .pantau)
    }
    
}
