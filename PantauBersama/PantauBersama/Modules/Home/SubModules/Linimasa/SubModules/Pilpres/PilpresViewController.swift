//
//  PilpresViewController.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 18/12/18.
//  Copyright © 2018 PantauBersama. All rights reserved.
//

import AsyncDisplayKit
import RxCocoa
import RxSwift

class PilpresViewController: ASViewController<ASTableNode> {
    
    private var context: ASBatchContext?
    private var disposeBag: DisposeBag = DisposeBag()
    private var viewModel: PilpresViewModel!
    private var emptyView = EmptyView()
    private var headerView: BannerHeaderView!
    
    private var rControl: UIRefreshControl?
    
    init(viewModel: PilpresViewModel) {
        self.viewModel = viewModel
        
        let tableNode = ASTableNode(style: .plain)
        tableNode.backgroundColor = .white
        tableNode.automaticallyManagesSubnodes = true
        super.init(node: tableNode)
        
        self.node.onDidLoad { (node) in
            guard let `node` = node as? ASTableNode else { return }
            node.view.separatorColor = UIColor.groupTableViewBackground
            node.view.tableFooterView = UIView()
            node.view.refreshControl = UIRefreshControl()
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
                    self.headerView = BannerHeaderView()
                    self.node.view.tableHeaderView = self.headerView
                    
                    self.viewModel.output.bannerInfo
                        .drive(onNext: { [unowned self] (banner) in
                            self.headerView.config(banner: banner, viewModel: self.viewModel.headerViewModel)
                        })
                        .disposed(by: self.disposeBag)
                }
            })
            .disposed(by: disposeBag)
        
        viewModel.output.feedsCells
            .do(onNext: { [weak self] (items) in
                guard let `self` = self else { return }
                self.node.view.backgroundView = nil
                if items.count == 0 {
                    self.emptyView.frame = self.node.view.bounds
                    self.node.view.backgroundView = self.emptyView
                } else {
                    self.node.view.backgroundView = nil
                }
                self.node.view.refreshControl?.endRefreshing()
            })
            .drive(onNext: { [weak self] (_) in
                guard let `self` = self else { return }
                self.node.reloadData()
                self.context?.completeBatchFetching(true)
                self.context = nil
            })
            .disposed(by: disposeBag)
        
        self.node.view.refreshControl?.rx.controlEvent(.valueChanged)
            .map({ (_) -> String in
                return ""
            })
            .bind(to: viewModel.input.refreshTrigger)
            .disposed(by: disposeBag)
        
        viewModel.output.moreSelected
            .asObservable()
            .flatMapLatest({ [weak self] (feeds) -> Observable<PilpresType> in
                return Observable.create({ (observer) -> Disposable in
                    
                    let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
                    let twitter = UIAlertAction(title: "Buka di Aplikasi Twitter", style: .default, handler: { (_) in
                        observer.onNext(PilpresType.twitter(data: feeds))
                        observer.on(.completed)
                    })
                    let cancel = UIAlertAction(title: "Batal", style: .cancel, handler: nil)
                    alert.addAction(twitter)
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
            .drive()
            .disposed(by: disposeBag)
        
        viewModel.output.itemSelected
            .drive()
            .disposed(by: disposeBag)
        
        viewModel.output.infoSelected
            .drive()
            .disposed(by: disposeBag)
        
        viewModel.output.filter
            .drive(onNext: { [weak self] (_) in
                guard let `self` = self else { return }
                self.node.view.refreshControl?.sendActions(for: .valueChanged)
                let indexPath = IndexPath(row: 0, section: 0)
                self.node.scrollToRow(at: indexPath, at: .top, animated: true)
            })
            .disposed(by: disposeBag)
    }
    
    
}

extension PilpresViewController: ASTableDelegate {
    func shouldBatchFetch(for tableNode: ASTableNode) -> Bool {
        return self.context == nil
    }
    func tableNode(_ tableNode: ASTableNode, willBeginBatchFetchWith context: ASBatchContext) {
        self.context = context
        self.viewModel.input.nextTrigger.onNext(())
    }
    
    func tableNode(_ tableNode: ASTableNode, didSelectRowAt indexPath: IndexPath) {
        self.viewModel.input.itemSelectTrigger.onNext(indexPath)
    }
}

extension PilpresViewController: ASTableDataSource {
    func numberOfSections(in tableNode: ASTableNode) -> Int {
        return 1
    }
    func tableNode(_ tableNode: ASTableNode, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.feeds.value.count
    }
    func tableNode(_ tableNode: ASTableNode, nodeBlockForRowAt indexPath: IndexPath) -> ASCellNodeBlock {
        return {
            guard self.viewModel.feeds.value.count > indexPath.row else { return ASCellNode() }
            let feeds = self.viewModel.feeds.value[indexPath.row]
            let cellNode = LinimasaNode(item: LinimasaNode.Input(viewModel: self.viewModel, feeds: feeds))
            return cellNode
        }
    }
}
