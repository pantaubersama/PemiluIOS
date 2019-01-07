//
//  AskController.swift
//  PantauBersama
//
//  Created by wisnu bhakti on 19/12/18.
//  Copyright © 2018 PantauBersama. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import Common

class QuestionController: UITableViewController {

    private let disposeBag: DisposeBag = DisposeBag()
    private var viewModel: QuestionViewModel!
    
    lazy var loadingIndicator: UIActivityIndicatorView = {
       let activityIndicator = UIActivityIndicatorView(style: .gray)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        return activityIndicator
    }()
    
    convenience init(viewModel: QuestionViewModel) {
        self.init()
        self.viewModel = viewModel
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(loadingIndicator)
        self.configureConstraint()
        
        tableView.registerReusableCell(AskViewCell.self)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 44
        tableView.separatorStyle = .singleLine
        tableView.separatorColor = UIColor.groupTableViewBackground
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        tableView.tableHeaderView = HeaderAskView(viewModel: viewModel)
        tableView.tableFooterView = UIView()
        
        bindViewModel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.input.loadQuestionTrigger
            .onNext(())
        
        tableView.delegate = nil
        tableView.dataSource = nil
        viewModel.output.question
            .asDriverOnErrorJustComplete()
            .drive(tableView.rx.items) { [unowned self]table, row, item -> UITableViewCell in
                // Loadmore trigger
                if row == self.viewModel.output.question.value.count - 3 {
                    self.viewModel.input.nextPageTrigger.onNext(())
                }
                guard let cell = table.dequeueReusableCell(withIdentifier: AskViewCell.reuseIdentifier) as? AskViewCell else {
                    return UITableViewCell()
                }
                
                cell.tag = row
                cell.configureCell(item: AskViewCell.Input(viewModel: self.viewModel, question: item))
                
                return cell
            }.disposed(by: disposeBag)
    }
    
    private func bindViewModel() {
        viewModel.output.loadingIndicator
            .map { !$0 }
            .drive(loadingIndicator.rx.isHidden)
            .disposed(by: disposeBag)
        
        viewModel.output.loadingIndicator
            .drive(loadingIndicator.rx.isAnimating)
            .disposed(by: disposeBag)
        
        viewModel.output.createSelected
            .drive()
            .disposed(by: disposeBag)
        
        viewModel.output.infoSelected
            .drive()
            .disposed(by: disposeBag)
        
        viewModel.output.shareSelected
            .drive()
            .disposed(by: disposeBag)
        
        viewModel.output.moreSelected
            .asObservable()
            .flatMapLatest({ [weak self] (question) -> Observable<QuestionType> in
                return Observable.create({ (observer) -> Disposable in
                    let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
                    let hapus = UIAlertAction(title: "Hapus", style: .default, handler: { (_) in
                        observer.onNext(QuestionType.hapus(question: question))
                        observer.on(.completed)
                    })
                    let salin = UIAlertAction(title: "Salin Tautan", style: .default, handler: { (_) in
                        observer.onNext(QuestionType.salin(question: question))
                        observer.on(.completed)
                    })
                    let bagikan = UIAlertAction(title: "Bagikan", style: .default, handler: { (_) in
                        observer.onNext(QuestionType.bagikan(question: question))
                        observer.on(.completed)
                    })
                    let laporkan = UIAlertAction(title: "Laporkan", style: .default, handler: { (_) in
                        observer.onNext(QuestionType.laporkan(question: question))
                        observer.on(.completed)
                    })
                    let cancel = UIAlertAction(title: "Batal", style: .cancel, handler: nil)
                    
                    if question.isMyQuestion {
                        alert.addAction(hapus)
                    }
                    
                    alert.addAction(salin)
                    alert.addAction(bagikan)
                    alert.addAction(laporkan)
                    alert.addAction(cancel)
                    DispatchQueue.main.async {
                        self?.navigationController?.present(alert, animated: true, completion: nil)
                    }
                    return Disposables.create()
                })
            })
            .bind(to: viewModel.input.moreMenuTrigger)
            .disposed(by: disposeBag)
        
        viewModel.output.moreMenuSelected
            .filter { !$0.isEmpty }
            .drive(onNext: { (message) in
                UIAlertController.showAlert(withTitle: "", andMessage: message)
            })
            .disposed(by: disposeBag)
        
        viewModel.output.filter
            .drive()
            .disposed(by: disposeBag)
    }
    
    private func configureConstraint() {
        NSLayoutConstraint.activate([
            loadingIndicator.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
            loadingIndicator.widthAnchor.constraint(equalToConstant: 30),
            loadingIndicator.heightAnchor.constraint(equalToConstant: 30)
            ])
    }
}
