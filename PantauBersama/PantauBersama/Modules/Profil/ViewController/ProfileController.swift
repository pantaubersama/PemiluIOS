//
//  ProfileController.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 21/12/18.
//  Copyright © 2018 PantauBersama. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import Common
import RxDataSources
import Networking

class ProfileController: UIViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var container: UIView!
    @IBOutlet weak var headerProfile: HeaderProfile!
    @IBOutlet weak var clusterButton: UIButton!
    @IBOutlet weak var biodataButton: UIButton!
    @IBOutlet weak var badgeButton: UIButton!
    @IBOutlet weak var heightTableBadgeConstant: NSLayoutConstraint!
    @IBOutlet weak var tableViewBadge: UITableView!
    @IBOutlet weak var clusterContainer: UIView!
    @IBOutlet weak var heightClusterConstant: NSLayoutConstraint!
    @IBOutlet weak var heightBiodataConstant: NSLayoutConstraint!
    @IBOutlet weak var clusterView: ClusterView!
    @IBOutlet weak var biodataView: BiodataView!
    @IBOutlet weak var lihatBadge: Button!
    @IBOutlet weak var containerLihat: UIView!
    @IBOutlet weak var containerlihatConstant: NSLayoutConstraint!
    
    var viewModel: IProfileViewModel!
    var isMyAccount: Bool = true // default is my account
    var userId: String? = nil
    private var isExpanded: Bool = false
    private var userResponse: User!
    
    lazy var myJanpolViewModel: MyJanpolListViewModel = MyJanpolListViewModel(navigator: viewModel.navigator, showTableHeader: false)
    lazy var myQuestionViewModel: MyQuestionListViewModel = MyQuestionListViewModel(navigator: viewModel.navigator, showTableHeader: false)
    
    lazy var userJanpolViewModel: UserJanpolListViewModel = UserJanpolListViewModel(navigator: viewModel.navigator, showTableHeader: false, userId: userId ?? "")
    lazy var userQuestionViewModel: UserQuestionListViewModel = UserQuestionListViewModel(navigator: viewModel.navigator, showTableHeader: false, userId: userId ?? "")
    
    private lazy var janjiController = isMyAccount ? JanjiPolitikViewController(viewModel: myJanpolViewModel) : JanjiPolitikViewController(viewModel: userJanpolViewModel)
    private lazy var tanyaController = isMyAccount ? QuestionController(viewModel: myQuestionViewModel) : QuestionController(viewModel: userQuestionViewModel)
    private lazy var emptyController = UIViewController()
    
    private let disposeBag = DisposeBag()
    private var dataSourceBadge: RxTableViewSectionedReloadDataSource<SectionOfProfileData>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Profil"
        // MARK
        // add child view
        add(childViewController: janjiController, context: container)
        add(childViewController: tanyaController, context: container)
        add(childViewController: emptyController, context: container)
        
        let back = UIBarButtonItem(image: #imageLiteral(resourceName: "back"), style: .plain, target: nil, action: nil)
        let setting = UIBarButtonItem(image: #imageLiteral(resourceName: "outlineSettings24Px"), style: .plain, target: nil, action: nil)
        
        navigationItem.rightBarButtonItem = isMyAccount ? setting : nil
        navigationItem.leftBarButtonItem = back
     
        
        // MARK
        // segmented control value
        segmentedControl.rx.value
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [unowned self] i in
                UIView.animate(withDuration: 0.3, animations: {
                    if i == 0 {
                        self.janjiController.view.alpha = 1.0
                        self.tanyaController.view.alpha = 0.0
                        self.emptyController.view.alpha = 0.0
                    } else if i == 1{
                        self.janjiController.view.alpha = 0.0
                        self.tanyaController.view.alpha = 1.0
                        self.emptyController.view.alpha = 0.0
                    } else {
                        self.janjiController.view.alpha = 0.0
                        self.tanyaController.view.alpha = 0.0
                        self.emptyController.view.alpha = 1.0
                    }
                })
            })
            .disposed(by: disposeBag)
        
        // MARK
        // Section Selected
        clusterButton.rx.tap.scan(self.isExpanded) { lastState, newValue in
            return !lastState
            }.subscribe(onNext: { [weak self] (value) in
                guard let `self` = self else { return }
                self.setView(view: self.clusterView, hidden: value)
            })
            .disposed(by: disposeBag)
        
        badgeButton.rx.tap.scan(self.isExpanded) { lastState, newValue in
            return !lastState
            }.subscribe(onNext: { [weak self] (value) in
                guard let `self` = self else { return }
                self.setView(view: self.tableViewBadge, hidden: value)
                self.setView(view: self.containerLihat, hidden: value)
            })
            .disposed(by: disposeBag)
        
        biodataButton.rx.tap.scan(self.isExpanded) { lastState, newValue in
            return !lastState
            }.subscribe(onNext: { [weak self] (value) in
                guard let `self` = self else { return }
                self.setView(view: self.biodataView, hidden: value)
            })
            .disposed(by: disposeBag)
        
        lihatBadge.rx.tap
            .bind(to: viewModel.input.lihatBadgeI)
            .disposed(by: disposeBag)
        
        // MARK
        // Handle scrollview
        Driver.merge([
                self.janjiController.tableView.rx.contentOffset.asDriver(),
                self.tanyaController.tableView.rx.contentOffset.asDriver()
            ])
            .drive(onNext: { [weak self] (position) in
                guard let `self` = self else { return }
                // need adjustment when user scroll tableview
                let headerViewHeight: CGFloat = 430 // calculate each subview from top to segmented
                let halfHeaderViewHeight = headerViewHeight / 2

                UIView.animate(withDuration: 0.3, animations: {
                    if position.y >= 0 && position.y <= halfHeaderViewHeight {
                        self.scrollView.contentOffset.y = position.y
                    } else  if position.y > halfHeaderViewHeight {
                        self.scrollView.contentOffset.y = headerViewHeight
                    } else {
                        self.scrollView.contentOffset.y = 0
                    }
                })

                let tableViews = [
                    self.janjiController.tableView,
                    self.tanyaController.tableView
                    ]
                tableViews.forEach{ (tableView) in
                        let minimumTableViewContentSizeHeight = halfHeaderViewHeight + tableView!.frame.height

                        if (position.y >= halfHeaderViewHeight)
                            && tableView!.contentSize.height < minimumTableViewContentSizeHeight {
                            tableView!.contentSize = CGSize(width: tableView!.contentSize.width,
                                                            height: minimumTableViewContentSizeHeight + 2)
                        }
                    }
                
            })
            .disposed(by: disposeBag)
        
        
        // MARK: - TableViews
        // Register TableViews
        tableViewBadge.dataSource = nil
        tableViewBadge.delegate = nil
        tableViewBadge.registerReusableCell(BadgeCell.self)
        tableViewBadge.tableFooterView = UIView()
        tableViewBadge.rowHeight = 50.0
        tableViewBadge.contentInset = UIEdgeInsets(top: 5, left: 0, bottom: 5, right: 0)
        
        dataSourceBadge = RxTableViewSectionedReloadDataSource<SectionOfProfileData>(configureCell: {
            (dataSource, tableView, indexPath, item) in
            guard let cell = tableView.dequeueReusableCell(withIdentifier: item.reuseIdentifier) else {
                return UITableViewCell()
            }
            item.configure(cell: cell)
            return cell
        })
        
        back.rx.tap
            .bind(to: viewModel.input.backI)
            .disposed(by: disposeBag)
        
        setting.rx.tap
            .bind(to: viewModel.input.settingI)
            .disposed(by: disposeBag)
        
        headerProfile.buttonVerified.rx.tap
            .bind(to: viewModel.input.verifikasiI)
            .disposed(by: disposeBag)
        
        viewModel.output.settingO
            .drive()
            .disposed(by: disposeBag)
        
        viewModel.output.verifikasiO
            .drive()
            .disposed(by: disposeBag)
        
        viewModel.output.itemsBadgeO
            .drive(tableViewBadge.rx.items(dataSource: dataSourceBadge))
            .disposed(by: disposeBag)
        
        viewModel.output.userDataO
            .drive(onNext: { [weak self] (response) in
                guard let `self` = self else { return }
                let user = response.user
                self.userResponse = user
                self.headerProfile.configure(user: user, isMyAccount: self.isMyAccount)
                self.clusterView.configure(data: user, isMyAccount: self.isMyAccount)
                self.biodataView.configure(data: user)
            })
            .disposed(by: disposeBag)
        
        viewModel.output.errorO
            .drive(onNext: { [weak self] (error) in
                guard let `self` = self else { return }
                guard let alert = UIAlertController.alert(with: error) else { return }
                self.navigationController?.present(alert, animated: true, completion: nil)
            })
            .disposed(by: disposeBag)
        
        clusterView.buttonReqCluster.rx.tap
            .bind(to: viewModel.input.reqClusterI)
            .disposed(by: disposeBag)
        
        viewModel.output.reqClusterO
            .drive()
            .disposed(by: disposeBag)
        
        clusterView.moreCluster.rx.tap
            .map({ self.userResponse })
            .flatMapLatest { (user) -> Observable<ClusterType> in
                return Observable<ClusterType>.create { [weak self] (observer) -> Disposable in
                    let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
                    let lihat = UIAlertAction(title: "Lihat Cluster", style: .default, handler: { (_) in
                        observer.onNext(.lihat(data: user))
                        observer.on(.completed)
                    })
                    let undang = UIAlertAction(title: "Undang Anggota", style: .default, handler: { (_) in
                        observer.onNext(.undang(data: user))
                        observer.on(.completed)
                    })
                    let leave = UIAlertAction(title: "Tinggalkan Cluster", style: .default, handler: { (_) in
                        observer.onNext(.leave)
                        observer.on(.completed)
                    })
                    let cancel = UIAlertAction(title: "Batal", style: .cancel, handler: { (_) in
                        observer.on(.completed)
                    })
                    alert.addAction(lihat)
                    alert.addAction(undang)
                    alert.addAction(leave)
                    alert.addAction(cancel)
                    DispatchQueue.main.async {
                        self?.navigationController?.present(alert, animated: true, completion: nil)
                    }
                    return Disposables.create()
                }
            }
            .bind(to: viewModel.input.clusterI)
            .disposed(by: disposeBag)
        
        viewModel.output.clusterActionO
            .drive()
            .disposed(by: disposeBag)
        
        viewModel.output.backO
            .drive()
            .disposed(by: disposeBag)
        
        viewModel.output.shareBadgeO
            .drive()
            .disposed(by: disposeBag)
        
        viewModel.output.lihatBadgeO
            .drive()
            .disposed(by: disposeBag)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.input.viewWillAppearI.onNext(())
        navigationController?.navigationBar.configure(with: .white)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.configure(with: .white)
    }
}


extension ProfileController {
    func setView(view: UIView, hidden: Bool) {
        UIView.transition(with: view, duration: 0.4, options: .transitionCrossDissolve, animations: {
            view.isHidden = hidden
            self.isExpanded = true
        })
    }
}
