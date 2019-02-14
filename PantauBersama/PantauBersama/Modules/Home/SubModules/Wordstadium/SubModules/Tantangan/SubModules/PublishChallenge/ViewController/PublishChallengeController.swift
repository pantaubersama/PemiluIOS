//
//  PublishChallengeController.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 14/02/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class PublishChallengeController: UIViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var promoteView: PromoteView!
    @IBOutlet weak var challengeDetail: ChallengeDetailView!
    @IBOutlet weak var footerProfileView: FooterProfileView!
    
    var viewModel: PublishChallengeViewModel!
    private let disposeBag: DisposeBag = DisposeBag()
    var tantanganType: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let back = UIBarButtonItem(image: #imageLiteral(resourceName: "back"), style: .plain, target: nil, action: nil)
        navigationItem.leftBarButtonItem = back
        title  = "Promote Your Challenge"
        
        back.rx.tap
            .bind(to: viewModel.input.backI)
            .disposed(by: disposeBag)
    }
    
    
}
