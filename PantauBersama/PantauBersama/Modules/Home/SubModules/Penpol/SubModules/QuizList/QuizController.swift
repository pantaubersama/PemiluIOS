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
    private var viewModel: QuizViewModel!
    
    convenience init(viewModel: QuizViewModel) {
        self.init()
        self.viewModel = viewModel
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.registerReusableCell(QuizCell.self)
        tableView.rowHeight = 350
        tableView.separatorStyle = .none
        tableView.allowsSelection = false
        tableView.tableHeaderView = HeaderQuizView(viewModel: viewModel)
        
        bindViewModel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        viewModel.input.loadQuizTrigger.onNext(())
        
        tableView.delegate = nil
        tableView.dataSource = nil
        let a = viewModel.output.quizzes
        a.bind(to: tableView.rx.items) { [unowned self]tableView, row, item -> UITableViewCell in
            // Loadmore trigger
            if row == self.viewModel.output.quizzes.value.count - 3 {
                self.viewModel.input.nextPageTrigger.onNext(())
            }
            guard let cell = tableView.dequeueReusableCell(withIdentifier: QuizCell.reuseIdentifier) as? QuizCell else {
                return UITableViewCell()
            }
            
            cell.configureCell(item: QuizCell.Input(viewModel: self.viewModel, quiz: item))
            cell.tag = row
            
            return cell
        }.disposed(by: disposeBag)
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
        
    }
}
