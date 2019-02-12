//
//  LiveDebatController.swift
//  PantauBersama
//
//  Created by Rahardyan Bisma Setya Putra on 12/02/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import UIKit
import Common
import RxSwift
import RxCocoa

class LiveDebatController: UIViewController {
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var tableViewDebat: UITableView!
    
    private lazy var titleView = Button()
    
    
    var viewModel: LiveDebatViewModel!
    
    private lazy var disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //for dummy ui
        tableViewDebat.dataSource = self
        tableViewDebat.tableFooterView = UIView()
        tableViewDebat.isScrollEnabled = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        configureNavbar()
        configureTitleView()
        
        scrollView.rx.contentOffset
            .distinctUntilChanged()
            .subscribe(onNext: { [unowned self](point) in
                self.configureCollapseNavbar(y: point.y, collaspingY: 135.0)
        }).disposed(by: disposeBag)
        
        
        viewModel.output.back
            .drive()
            .disposed(by: disposeBag)
    }
    
    private func configureNavbar() {
        let back = UIBarButtonItem(image: #imageLiteral(resourceName: "back"), style: .plain, target: nil, action: nil)
        self.navigationItem.leftBarButtonItem = back
        
        let more = UIBarButtonItem(image: #imageLiteral(resourceName: "icMoreVerticalWhite"), style: .plain, target: nil, action: nil)
        self.navigationItem.rightBarButtonItem = more
        
        self.navigationController?.navigationBar.configure(with: .transparent)
        
        back.rx.tap
            .bind(to: viewModel.input.backTrigger)
            .disposed(by: disposeBag)
    }
    
    private func configureTitleView() {
        titleView.isHidden = true
        titleView.translatesAutoresizingMaskIntoConstraints = false
        titleView.typeButton = "bold"
        titleView.fontSize = 14
        titleView.setTitle("LIVE NOW", for: .normal)
        titleView.setImage(#imageLiteral(resourceName: "outlineLiveRed24Px"), for: .normal)
        titleView.imageEdgeInsets = UIEdgeInsets(top: 0, left: -10, bottom: 0, right: 0)
        titleView.isUserInteractionEnabled = false
        
        if let navBar = self.navigationController?.navigationBar {
            navBar.addSubview(titleView)
            NSLayoutConstraint.activate([
                titleView.centerYAnchor.constraint(equalTo: navBar.centerYAnchor),
                titleView.centerXAnchor.constraint(equalTo: navBar.centerXAnchor),
                titleView.topAnchor.constraint(equalTo: navBar.topAnchor),
                titleView.bottomAnchor.constraint(equalTo: navBar.bottomAnchor),
                titleView.widthAnchor.constraint(equalToConstant: 100)
                ])
        }
    }
    
    private func configureCollapseNavbar(y: CGFloat, collaspingY: CGFloat) {
        if y > collaspingY && self.navigationController?.navigationBar.barTintColor != Color.secondary_orange { // collapsed
            self.tableViewDebat.isScrollEnabled = true
            UIView.animate(withDuration: 0.3, animations: {
                self.navigationController?.navigationBar.barTintColor = Color.secondary_orange
                self.navigationController?.navigationBar.backgroundColor = Color.secondary_orange
            })
            self.titleView.isHidden = false
        } else if y < collaspingY && self.navigationController?.navigationBar.barTintColor != UIColor.clear { // expanded
            self.tableViewDebat.isScrollEnabled = false
            UIView.animate(withDuration: 0.5, animations: {
                self.navigationController?.navigationBar.configure(with: .transparent)
            })
            self.titleView.isHidden = true
        }
    }
}

extension LiveDebatController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 20
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = "hahahahahahaha"
        
        return cell
    }
    
    
}
