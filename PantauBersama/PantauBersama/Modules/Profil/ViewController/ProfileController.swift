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

class ProfileController: UIViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var container: UIView!
    
    private lazy var pilpresController = PilpresViewController()
    private lazy var janjiController = JanjiPolitikViewController()
    
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // MARK
        // add child view
        add(childViewController: pilpresController, context: container)
        add(childViewController: janjiController, context: container)
        
        let back = UIBarButtonItem(image: #imageLiteral(resourceName: "back"), style: .plain, target: self, action: #selector(handleBack(sender:)))
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
        // Handle scrollview
        Driver.merge([
                self.pilpresController.tableView.rx.contentOffset.asDriver(),
                self.janjiController.tableView.rx.contentOffset.asDriver()
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
                    self.pilpresController.tableView,
                    self.janjiController.tableView
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
        tableView.registerReusableCell(SectionCell.self)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = 44.0
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    @objc private func handleBack(sender: UIBarButtonItem) {
        navigationController?.popViewController(animated: true)
    }
}

// Dummy
// Strategy tableview begin updates, delete rows
// need contact designer again ... hhh
extension ProfileController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return 3
        case 2:
            return 4
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(indexPath: indexPath) as SectionCell
        return cell
    }
    
}
