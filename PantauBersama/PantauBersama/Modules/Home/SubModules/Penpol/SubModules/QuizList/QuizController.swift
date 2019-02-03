//
//  QuizController.swift
//  PantauBersama
//
//  Created by Rahardyan Bisma on 20/12/18.
//  Copyright © 2018 PantauBersama. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Common
import AlamofireImage

class QuizController: UITableViewController {
    private let disposeBag: DisposeBag = DisposeBag()
    private lazy var emptyView = EmptyView()
    private var viewModel: QuizViewModel!
    lazy var tableHeaderView = HeaderQuizView()
    
    convenience init(viewModel: QuizViewModel) {
        self.init()
        self.viewModel = viewModel
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = nil
        tableView.dataSource = nil
        tableView.registerReusableCell(QuizCell.self)
        tableView.rowHeight = 350
        tableView.separatorStyle = .none
        tableView.allowsSelection = false
        
        viewModel.output.showHeader
            .drive(onNext: { [unowned self]isHeaderShown in
                if isHeaderShown {
                    self.tableView.tableHeaderView = self.tableHeaderView
                    self.tableHeaderView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 115)
                }
            })
            .disposed(by: disposeBag)
        
        tableHeaderView.config(viewModel: viewModel)
        
        viewModel.output.quizzes
            .do(onNext: {  [unowned self](items) in
                self.tableView.backgroundView = nil
                if items.count == 0 {
                    self.emptyView.frame = self.tableView.bounds
                    self.tableView.backgroundView = self.emptyView
                } else {
                    self.tableView.backgroundView = nil
                }
            })
            .bind(to: tableView.rx.items) { [unowned self]tableView, row, item -> UITableViewCell in
                // Loadmore trigger
                if row == self.viewModel.output.quizzes.value.count - 1 {
                    self.viewModel.input.nextPageTrigger.onNext(())
                }
                guard let cell = tableView.dequeueReusableCell(withIdentifier: QuizCell.reuseIdentifier) as? QuizCell else {
                    return UITableViewCell()
                }
                
                cell.configureCell(item: QuizCell.Input(viewModel: self.viewModel, quiz: item))
                cell.tag = row
                
                return cell
            }.disposed(by: disposeBag)
        
        bindViewModel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        viewModel.input.loadQuizTrigger.onNext(())
        
    }
    
    private func bindViewModel() {
        viewModel.output.openQuizSelected
            .drive()
            .disposed(by: disposeBag)
        
        viewModel.output.shareSelected
            .drive()
            .disposed(by: disposeBag)
        
        viewModel.output.infoSelected
            .drive()
            .disposed(by: disposeBag)
        
        viewModel.output.shareTrendSelected
            .drive()
            .disposed(by: disposeBag)
        
        viewModel.output.filter
            .drive()
            .disposed(by: disposeBag)
        
        viewModel.output.totalResult
            .drive(onNext: { [unowned self] (result) in
                if result.meta.quizzes.finished >= 1{
                    self.tableHeaderView.trendHeaderView.isHidden = false
                    self.tableHeaderView.trendHeaderView.config(result: result, viewModel: self.viewModel)
                    self.tableHeaderView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 115 + 212)
                }

            })
            .disposed(by: disposeBag)
    }
    
}

