//
//  ShareTrendController.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 20/01/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Common

class ShareTrendController: UIViewController {
    
    @IBOutlet weak var ivPaslon: CircularUIImageView!
    @IBOutlet weak var lblPercentage: UILabel!
    @IBOutlet weak var lblTeam: UILabel!
    @IBOutlet weak var share: Button!
    @IBOutlet weak var lblDesc: Label!
    @IBOutlet weak var lblUsername: Label!
    @IBOutlet weak var lblSubDesc: Label!
    
    var viewModel: ShareTrendViewModel!
    private let disposeBag: DisposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        lblUsername.sizeToFit()
        let back = UIBarButtonItem(image: #imageLiteral(resourceName: "back"), style: .plain, target: nil, action: nil)
        navigationItem.leftBarButtonItem = back
        
        share.rx.tap
            .bind(to: viewModel.input.shareI)
            .disposed(by: disposeBag)
        
        back.rx.tap
            .bind(to: viewModel.input.backI)
            .disposed(by: disposeBag)
        
        viewModel.output.dataO
            .drive(onNext: { [weak self] (response) in
                guard let `self` = self else { return }
                  let kecenderungan = response.teams.max { $0.percentage?.isLess(than: $1.percentage ?? 0.0) ?? false }
                    if let avatarUrl = kecenderungan?.team.avatar {
                        self.ivPaslon.af_setImage(withURL: URL(string: avatarUrl)!)
                    }
                    self.lblDesc.text = "Total Kecenderunganmu \(response.meta.quizzes.finished) dari \(response.meta.quizzes.total) kuis,"
                    self.lblUsername.text = response.user.fullName
                    self.lblSubDesc.text = " lebih suka jawaban dari Paslon no \(kecenderungan?.team.id ?? 0)"
                    self.lblPercentage.text = "\(Double(kecenderungan?.percentage ?? 0.0))%"
                    self.lblTeam.text = "\(kecenderungan?.team.title ?? "")"
            })
            .disposed(by: disposeBag)
        
        viewModel.output.shareO
            .drive()
            .disposed(by: disposeBag)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.configure(with: .transparent)
        self.navigationController?.navigationBar.tintColor = #colorLiteral(red: 0.3333333433, green: 0.3333333433, blue: 0.3333333433, alpha: 1)
        viewModel.input.viewWillAppearI.onNext(())
    }
    
}
