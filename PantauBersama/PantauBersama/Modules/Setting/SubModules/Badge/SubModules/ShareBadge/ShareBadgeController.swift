//
//  ShareBadgeController.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 07/01/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Common

class ShareBadgeController: UIViewController {
    
    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var fullname: Label!
    @IBOutlet weak var about: Label!
    @IBOutlet weak var iconBadges: UIImageView!
    @IBOutlet weak var titleBadges: Label!
    @IBOutlet weak var subtitleBadges: Label!
    
    var viewModel: ShareBadgeViewModel!
    private let disposeBag: DisposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let share = UIBarButtonItem(image: #imageLiteral(resourceName: "icShare"), style: .plain, target: nil, action: nil)
        let back = UIBarButtonItem(image: #imageLiteral(resourceName: "back"), style: .plain, target: nil, action: nil)
        navigationItem.leftBarButtonItem = back
        navigationItem.rightBarButtonItem = share
        
        back.rx.tap
            .bind(to: viewModel.input.backI)
            .disposed(by: disposeBag)
        
        viewModel.output.dataO
            .drive(onNext: { [weak self] (response) in
                guard let `self` = self else { return }
                if let thumbnail = response.achieved.user?.avatar?.thumbnail.url {
                    self.avatar.af_setImage(withURL: URL(string: thumbnail)!)
                }
                if let iconThumb = response.achieved.badge.image.thumbnail.url {
                    self.iconBadges.af_setImage(withURL: URL(string: iconThumb)!)
                }
                self.fullname.text = response.achieved.user?.fullName
                self.about.text = response.achieved.user?.about
                self.titleBadges.text = response.achieved.badge.name
                self.subtitleBadges.text = response.achieved.badge.description
            })
            .disposed(by: disposeBag)
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBar.configure(with: .white)
        viewModel.input.viewWillAppearI.onNext(())
    }
    
}
