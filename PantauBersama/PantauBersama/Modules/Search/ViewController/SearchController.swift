//
//  SearchController.swift
//  PantauBersama
//
//  Created by Rahardyan Bisma on 13/01/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class SearchController: UIViewController {
    @IBOutlet weak var navbar: SearchNavbar!
    @IBOutlet weak var customMenuBar: CustomMenuBar!
    @IBOutlet weak var container: UIView!
    @IBOutlet weak var tableViewRecentlySearched: UITableView!
    
    var viewModel: SearchViewModel!
    private let disposeBag = DisposeBag()
    
    lazy var quizViewModel = QuizViewModel(navigator: viewModel.navigator, showTableHeader: false)
    lazy var askViewModel = QuestionListViewModel(navigator: viewModel.navigator, showTableHeader: false)
    lazy var pilpresViewModel = PilpresViewModel(navigator: viewModel.navigator, searchTrigger: viewModel.searchSubject, showTableHeader: false)
    lazy var janjiPolitikViewModel = JanpolListViewModel(navigator: viewModel.navigator, searchTrigger: viewModel.searchSubject,    showTableHeader: false)
    lazy var listUserViewModel = ListUserViewModel(searchTrigger: viewModel.searchSubject)
    
    lazy var askController = QuestionController(viewModel: askViewModel)
    lazy var quisController = QuizController(viewModel: quizViewModel)
    lazy var pilpresController = PilpresViewController(viewModel: pilpresViewModel)
    lazy var janjiController = JanjiPolitikViewController(viewModel: janjiPolitikViewModel)
    lazy var listUserController = ListUserController(viewModel: listUserViewModel)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableViewRecentlySearched.tableFooterView = UIView()
        
        add(childViewController: quisController, context: container)
        add(childViewController: askController, context: container)
        add(childViewController: janjiController, context: container)
        add(childViewController: pilpresController, context: container)
        add(childViewController: listUserController, context: container)
        
        customMenuBar.menuItem = [MenuItem(title: "Orang"),
                                  MenuItem(title: "Cluster"),
                                  MenuItem(title: "Linimasa"),
                                  MenuItem(title: "Janji Politik"),
                                  MenuItem(title: "Tanya"),
                                  MenuItem(title: "Quiz"),
                                  MenuItem(title: "Wordstadium")]
        navbar.btnBack.rx.tap
            .bind(to: viewModel.input.backTrigger)
            .disposed(by: disposeBag)
        
        navbar.tfSearch.rx.text
            .orEmpty
            .do(onNext: { [unowned self](text) in
                self.tableViewRecentlySearched.isHidden = !text.isEmpty
                self.viewModel.input.loadRecentlySearched.onNext(())
            })
            .debounce(0.5, scheduler: MainScheduler.instance)
            .bind(to: viewModel.input.searchInputTrigger).disposed(by: disposeBag)
        
        
        viewModel.output.back
            .drive()
            .disposed(by: disposeBag)
        
        customMenuBar.selectedIndex
            .drive(onNext: { (index) in
                UIView.animate(withDuration: 0.3, animations: { [unowned self] in
                    self.hideAllChilds()
                    switch index {
                    case 0:
                        self.listUserController.view.alpha = 1.0
                        break
                    case 1:
                        break
                    case 2:
                        self.pilpresController.view.alpha = 1.0
                        break
                    case 3:
                        self.janjiController.view.alpha = 1.0
                        break
                    case 4:
                        self.askController.view.alpha = 1.0
                        break
                    case 5:
                        self.quisController.view.alpha = 1.0
                        break
                    case 6:
                        break
                    default:
                        break
                    }
                })
            })
            .disposed(by: disposeBag)
        
        viewModel.output.recentlySearched
            .drive(tableViewRecentlySearched.rx.items) { tableView, row, item -> UITableViewCell in
                let cell = UITableViewCell()
                cell.textLabel?.text = item
                
                return cell
            }
            .disposed(by: disposeBag)
        
        self.viewModel.input.loadRecentlySearched.onNext(())
    }
    
    private func hideAllChilds() {
        self.askController.view.alpha = 0.0
        self.quisController.view.alpha = 0.0
        self.pilpresController.view.alpha = 0.0
        self.janjiController.view.alpha = 0.0
        self.listUserController.view.alpha = 0.0
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.isHidden = false
    }

}
