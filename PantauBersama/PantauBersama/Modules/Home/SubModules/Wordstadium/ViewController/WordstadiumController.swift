//
//  WordstadiumController.swift
//  PantauBersama
//
//  Created by wisnu bhakti on 11/02/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Common
import AlamofireImage

class WordstadiumController: UIViewController {

    @IBOutlet weak var navbar: Navbar!
    @IBOutlet weak var segmentedControl: SegementedControl!
    @IBOutlet weak var container: UIView!
    @IBOutlet weak var tooltipButton: UIButton!
    @IBOutlet weak var containerTooltip: RoundView!
    
    var viewModel: WordstadiumViewModel!
    private let disposeBag = DisposeBag()
    
    
    private lazy var publicViewModel = LiniPublicViewModel(navigator: viewModel.navigator, showTableHeader: true)
    private lazy var personalViewModel = LiniPersonalViewModel(navigator: viewModel.navigator, showTableHeader: true)
    
    private lazy var personalController = LiniWordstadiumViewController(viewModel: personalViewModel)
    private lazy var publicController = LiniWordstadiumViewController(viewModel: publicViewModel)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navbar.backgroundColor = Color.secondary_orange
        
        add(childViewController: publicController, context: container)
        add(childViewController: personalController, context: container)
        
        // MARK
        // segmented control value
        // assign extension Reactive UIControl
        segmentedControl.rx.value
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [unowned self] i in
                UIView.animate(withDuration: 0.3, animations: {
                    if i == 0 {
                        self.personalController.view.alpha = 0.0
                        self.publicController.view.alpha = 1.0
                        self.containerTooltip.alpha = 0.0
                    } else {
                        self.personalController.view.alpha = 1.0
                        self.publicController.view.alpha = 0.0
                        self.containerTooltip.alpha = 1.0
                        self.containerTooltip.isHidden = false
                    }
                })
            })
            .disposed(by: disposeBag)
        
        
        // MARK
        // bind to viewModel
        navbar.search.rx.tap
            .bind(to: viewModel.input.searchTrigger)
            .disposed(by: disposeBag)
        
        navbar.notification.rx.tap
            .bind(to: viewModel.input.notificationTrigger)
            .disposed(by: disposeBag)
        
        navbar.profile.rx.tap
            .bind(to: viewModel.input.profileTrigger)
            .disposed(by: disposeBag)
        
        navbar.note.rx.tap
            .bind(to: viewModel.input.catatanTrigger)
            .disposed(by: disposeBag)
        
        
        tooltipButton.rx.tap
            .bind(to: viewModel.input.tooltipTriigger)
            .disposed(by: disposeBag)
        
        viewModel.output.profileSelected
            .drive()
            .disposed(by: disposeBag)
        
        viewModel.output.catatanSelected
            .drive()
            .disposed(by: disposeBag)
        
        viewModel.output.searchSelected
            .drive()
            .disposed(by: disposeBag)
        
        viewModel.output.userO
            .drive(onNext: { [weak self] (response) in
                guard let `self` = self else { return }
                let user = response.user
                if let thumbnail = user.avatar.thumbnail.url {
                    self.navbar.avatar.af_setImage(withURL: URL(string: thumbnail)!)
                }
            })
            .disposed(by: disposeBag)
        
        viewModel.output.notificationSelected
            .drive()
            .disposed(by: disposeBag)
        
        viewModel.output.tooltipSelected
            .drive()
            .disposed(by: disposeBag)
        
        
        let left = UISwipeGestureRecognizer(target: self, action: #selector(swipeLeft))
        left.direction = .left
        self.view.addGestureRecognizer(left)
        
        let right = UISwipeGestureRecognizer(target: self, action: #selector(swipeRight))
        right.direction = .right
        self.view.addGestureRecognizer(right)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBar.isHidden = true
        viewModel.input.viewWillAppearTrigger.onNext(())
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        navigationController?.navigationBar.isHidden = false
    }
    
    @objc func swipeLeft() {
        self.segmentedControl.swipeLeft()
        
    }
    
    @objc func swipeRight() {
        self.segmentedControl.swipeRight()
    }
}
