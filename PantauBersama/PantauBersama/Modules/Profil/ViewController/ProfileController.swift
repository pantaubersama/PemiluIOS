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
//    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var container: UIView!
    @IBOutlet weak var headerProfile: HeaderProfile!
    @IBOutlet weak var clusterButton: UIButton!
    @IBOutlet weak var biodataButton: UIButton!
    @IBOutlet weak var badgeButton: UIButton!
    @IBOutlet weak var heightTableClusterConstant: NSLayoutConstraint!
    @IBOutlet weak var heightTableBadgeConstant: NSLayoutConstraint!
    
    var viewModel: IProfileViewModel!
    
    lazy var janjiViewModel: JanjiPolitikViewModel = JanjiPolitikViewModel(navigator: viewModel.navigatorLinimasa)
    lazy var tanyaViewModel: AskViewModel = AskViewModel(navigator: viewModel.navigatorPenpol)
    
    private lazy var janjiController = JanjiPolitikViewController(viewModel: janjiViewModel)
    private lazy var tanyaController = AskController(viewModel: tanyaViewModel)
    
    private let disposeBag = DisposeBag()
    private var dataSource: RxTableViewSectionedReloadDataSource<SectionOfProfileData>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // MARK
        // add child view
        add(childViewController: janjiController, context: container)
        add(childViewController: tanyaController, context: container)
        
        let back = UIBarButtonItem(image: #imageLiteral(resourceName: "back"), style: .plain, target: nil, action: nil)
        let setting = UIBarButtonItem(image: #imageLiteral(resourceName: "outlineSettings24Px"), style: .plain, target: nil, action: nil)
        let cluster = UIBarButtonItem(image: #imageLiteral(resourceName: "icLaporActive"), style: .plain, target: nil, action: nil)
        
        navigationItem.rightBarButtonItems = [setting, cluster]
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
                UIView.animate(withDuration: 0.3, animations: {
                    self.heightTableClusterConstant.constant = value ? 47.0 : 0.0
                })
            })
            .disposed(by: disposeBag)
        
        badgeButton.rx.tap.scan(false) { lastState, newValue in
            return !lastState
            }.subscribe(onNext: { [weak self] (value) in
                guard let `self` = self else { return }
                UIView.animate(withDuration: 0.3, animations: {
                    self.heightTableBadgeConstant.constant = value ? 190.0 : 0.0
                })
            })
            .disposed(by: disposeBag)
        
        // MARK
        // Handle scrollview
        Driver.merge([
                self.janjiController.tableView.rx.contentOffset.asDriver(),
                self.tanyaController.tableView.rx.contentOffset.asDriver()
            ])
            .drive(onNext: { (position) in
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
//        tableView.dataSource = nil
//        tableView.delegate = nil
//        tableView.registerReusableCell(ClusterCell.self)
//        tableView.registerReusableCell(IconTableCell.self)
//        tableView.registerReusableCell(BadgeCell.self)
//
//        tableView.estimatedRowHeight = 44.0
//        tableView.rowHeight = UITableView.automaticDimension
//        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
//        tableView.tableFooterView = UIView()
        
//        dataSource = RxTableViewSectionedReloadDataSource<SectionOfProfileData>(configureCell: { (dataSource, tableView, indexPath, item) in
//                guard let cell = tableView.dequeueReusableCell(withIdentifier: item.reuseIdentifier) else {
//                    return UITableViewCell()
//                }
//                item.configure(cell: cell)
//                return cell
//        })
        
//        tableView.rx
//            .setDelegate(self)
//            .disposed(by: disposeBag)
        
        back.rx.tap
            .bind(to: viewModel.input.backI)
            .disposed(by: disposeBag)
        
        setting.rx.tap
            .bind(to: viewModel.input.settingI)
            .disposed(by: disposeBag)
        
        cluster.rx.tap
            .bind(to: viewModel.input.clusterI)
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
        
//        viewModel.output.itemsO
//            .drive(tableView.rx.items(dataSource: dataSource))
//            .disposed(by: disposeBag)
        
        viewModel.output.clusterO
            .drive()
            .disposed(by: disposeBag)
        
        viewModel.output.userDataO
            .drive(onNext: { [weak self] (response) in
                guard let `self` = self else { return }
                let user = response.user
                self.headerProfile.configure(user: user)
            })
            .disposed(by: disposeBag)
        
        viewModel.output.errorO
            .drive(onNext: { [weak self] (error) in
                guard let `self` = self else { return }
                guard let alert = UIAlertController.alert(with: error) else { return }
                self.navigationController?.present(alert, animated: true, completion: nil)
            })
            .disposed(by: disposeBag)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
}

extension ProfileController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 45.0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = SectionCell()
        view.label.text = dataSource.sectionModels[section].header
        return view
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 1.0))
        return view
    }
}
