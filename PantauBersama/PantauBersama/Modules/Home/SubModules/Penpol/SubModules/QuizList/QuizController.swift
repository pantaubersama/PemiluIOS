//
//  QuizController.swift
//  PantauBersama
//
//  Created by Rahardyan Bisma on 20/12/18.
//  Copyright © 2018 PantauBersama. All rights reserved.
//

import AsyncDisplayKit
import RxSwift
import RxCocoa
import Common

class QuizController: ASViewController<ASTableNode> {
    
    private let disposeBag: DisposeBag = DisposeBag()
    private lazy var emptyView = EmptyView()
    private var viewModel: QuizViewModel!
    lazy var tableHeaderView = HeaderQuizView()
    private var context: ASBatchContext?
    
    init(viewModel: QuizViewModel) {
        self.viewModel = viewModel
        
        let tableNode = ASTableNode(style: .plain)
        tableNode.backgroundColor = .white
        tableNode.automaticallyManagesSubnodes = true
        super.init(node: tableNode)
        
        self.node.onDidLoad { (node) in
            guard let `node` = node as? ASTableNode else { return }
            node.view.separatorColor = Color.RGBColor(red: 244, green: 244, blue: 244)
            node.view.tableFooterView = UIView()
        }
        
        self.node.leadingScreensForBatching = 2.0
        self.node.dataSource = self
        self.node.delegate = self
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.output.showHeader
            .drive(onNext: { [unowned self] (isHeaderShown) in
                if isHeaderShown {
                    self.node.view.tableHeaderView = self.tableHeaderView
                    self.tableHeaderView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 115)
                }
            })
            .disposed(by: disposeBag)
        
        tableHeaderView.config(viewModel: viewModel)
        
        
        viewModel.output.quizzes
            .do(onNext: { [unowned self] (items) in
                self.node.view.backgroundView = nil
                if items.count == 0 {
                    self.emptyView.frame = self.node.view.bounds
                    self.node.view.backgroundView = self.emptyView
                } else {
                    self.node.view.backgroundView = nil
                }
            })
            .asDriverOnErrorJustComplete()
            .drive(onNext: { [weak self] (_) in
                guard let `self` = self else { return }
                self.node.reloadData()
                self.context?.completeBatchFetching(true)
                self.context = nil
            })
            .disposed(by: disposeBag)
        
        bindViewModel()
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.input.loadQuizTrigger.onNext(())
    }
    
}

extension QuizController: ASTableDelegate {
    func shouldBatchFetch(for tableNode: ASTableNode) -> Bool {
        return self.context == nil
    }
    func tableNode(_ tableNode: ASTableNode, willBeginBatchFetchWith context: ASBatchContext) {
        self.context = context
        self.viewModel.input.nextPageTrigger.onNext(())
    }
    func tableNode(_ tableNode: ASTableNode, didSelectRowAt indexPath: IndexPath) {
        
    }
}

extension QuizController: ASTableDataSource {
    func numberOfSections(in tableNode: ASTableNode) -> Int {
        return 1
    }
    func tableNode(_ tableNode: ASTableNode, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.output.quizzes.value.count
    }
    func tableNode(_ tableNode: ASTableNode, nodeBlockForRowAt indexPath: IndexPath) -> ASCellNodeBlock {
        return {
            guard self.viewModel.output.quizzes.value.count > indexPath.row else { return ASCellNode() }
            let quiz = self.viewModel.output.quizzes.value[indexPath.row]
            let cellNode = QuizNode(item: QuizNode.Input(viewModel: self.viewModel, quiz: quiz))
            return cellNode
        }
    }
}
