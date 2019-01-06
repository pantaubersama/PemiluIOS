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
    
    var viewModel: IProfileViewModel!
    
    lazy var janjiViewModel: JanjiPolitikViewModel = JanjiPolitikViewModel(navigator: viewModel.navigatorLinimasa)
    lazy var tanyaViewModel: JanjiPolitikViewModel = JanjiPolitikViewModel(navigator: viewModel.navigatorLinimasa)
    
    private lazy var janjiController = JanjiPolitikViewController(viewModel: janjiViewModel)
    private lazy var tanyaController = JanjiPolitikViewController(viewModel: tanyaViewModel)
    
    private let disposeBag = DisposeBag()
    private var dataSourceBadge: RxTableViewSectionedReloadDataSource<SectionOfProfileData>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.clusterView.isHidden = true
        self.biodataView.isHidden = true
        // MARK
        // add child view
        add(childViewController: janjiController, context: container)
        add(childViewController: tanyaController, context: container)
        
        let back = UIBarButtonItem(image: #imageLiteral(resourceName: "back"), style: .plain, target: nil, action: nil)
        let setting = UIBarButtonItem(image: #imageLiteral(resourceName: "outlineSettings24Px"), style: .plain, target: nil, action: nil)
        
        navigationItem.rightBarButtonItem = setting
        navigationItem.leftBarButtonItem = back
        navigationController?.navigationBar.configure(with: .white)
        
        // MARK
        // segmented control value
        segmentedControl.rx.value
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [unowned self] i in
                UIView.animate(withDuration: 0.3, animations: {
                    if i == 0 {
                        self.janjiController.view.alpha = 1.0
                        self.tanyaController.view.alpha = 0.0
                    } else {
                        self.janjiController.view.alpha = 0.0
                        self.tanyaController.view.alpha = 1.0
                    }
                })
            })
            .disposed(by: disposeBag)
        
        // MARK
        // Section Selected
        clusterButton.rx.tap.scan(false) { lastState, newValue in
            return !lastState
            }.subscribe(onNext: { [weak self] (value) in
                guard let `self` = self else { return }
                UIView.performWithoutAnimation {
                    self.heightClusterConstant.constant = value ? 48.0 : 0.0
                    self.clusterView.isHidden = !value
                }
            })
            .disposed(by: disposeBag)
        
        badgeButton.rx.tap.scan(false) { lastState, newValue in
            return !lastState
            }.subscribe(onNext: { [weak self] (value) in
                guard let `self` = self else { return }
                UIView.performWithoutAnimation {
                    self.heightTableBadgeConstant.constant = value ? 190.0 : 0.0
                    self.tableViewBadge.isHidden = !value
                }
            })
            .disposed(by: disposeBag)
        
        biodataButton.rx.tap.scan(false) { lastState, newValue in
            return !lastState
            }.subscribe(onNext: { [weak self] (value) in
                guard let `self` = self else { return }
                UIView.performWithoutAnimation {
                    self.heightBiodataConstant.constant = value ? 86.0 : 0.0
                    self.biodataView.isHidden = !value
                }
            })
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
                self.heightClusterConstant.constant = 0.0
                self.heightBiodataConstant.constant = 0.0
                self.heightTableBadgeConstant.constant = 0.0
                let headerViewHeight: CGFloat = 347 // calculate each subview from top to segmented
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
        
        dataSourceBadge = RxTableViewSectionedReloadDataSource<SectionOfProfileData>(configureCell: {
            (dataSource, tableView, indexPath, item) in
            guard let cell = tableView.dequeueReusableCell(withIdentifier: item.reuseIdentifier) else {
                return UITableViewCell()
            }
            item.configure(cell: cell)
            return cell
        })
        
        tableViewBadge.rx.setDelegate(self)
            .disposed(by: disposeBag)
        
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
                self.headerProfile.configure(user: user)
                self.clusterView.configure(data: user)
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
            .flatMapLatest { (_) -> Observable<ClusterType> in
                return Observable<ClusterType>.create { [weak self] (observer) -> Disposable in
                    let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
                    let undang = UIAlertAction(title: "Undang Anggota", style: .default, handler: { (_) in
                        observer.onNext(.undang)
                        observer.on(.completed)
                    })
                    let leave = UIAlertAction(title: "Tinggalkan Cluster", style: .default, handler: { (_) in
                        observer.onNext(.leave)
                        observer.on(.completed)
                    })
                    let cancel = UIAlertAction(title: "Batal", style: .cancel, handler: { (_) in
                        observer.on(.completed)
                    })
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
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.input.viewWillAppearI.onNext(())
    }
}

extension ProfileController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let button = Button()
        button.setTitle("Lihat Lainnya", for: .normal)
        button.setTitleColor(Color.grey_one, for: .normal)
        return button
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 20.0
    }
}
