//
//  ChallengeController.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 15/02/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Common

class ChallengeController: UIViewController {
    
    @IBOutlet weak var containerHeader: UIView!
    @IBOutlet weak var lblHeader: UILabel!
    @IBOutlet weak var headerTantanganView: HeaderTantanganView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var challengeButton: ChallengeButtonView!
    @IBOutlet weak var containerContent: UIView!
    @IBOutlet weak var imageContent: UIImageView!
    @IBOutlet weak var titleContent: UILabel!
    @IBOutlet weak var subtitleContent: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var containerAcceptChallenge: UIView!
    @IBOutlet weak var containerTerima: RoundView!
    @IBOutlet weak var btnTerima: Button!
    @IBOutlet weak var btnImageTerima: UIImageView!
    @IBOutlet weak var containerTolak: RoundView!
    @IBOutlet weak var btnTolak: Button!
    @IBOutlet weak var containerDebatDone: UIView!
    
    @IBOutlet weak var btnBack: ImageButton!
    
    var viewModel: ChallengeViewModel!
    private let disposeBag: DisposeBag = DisposeBag()
    var type: ChallengeType = .default
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        btnBack.rx.tap
            .bind(to: viewModel.input.backI)
            .disposed(by: disposeBag)
        
        
        viewModel.output.backO
            .drive()
            .disposed(by: disposeBag)
        
        configureContent(type: self.type)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.isHidden = false
    }
}

extension ChallengeController {
    
    // MARK
    // Check if user id match or not
    // if user id not match the view will be present as user prespective value
    private func configureContent(type: ChallengeType) {
        switch type {
        case .challenge:
            self.titleContent.text = "Menunggu,"
            self.subtitleContent.text = "lawan menerima\ntantanganmu"
            self.containerHeader.backgroundColor = #colorLiteral(red: 1, green: 0.4935973287, blue: 0.3663615584, alpha: 1)
            self.lblHeader.text = "OPEN CHALLENGE" // asuume can change to direct
        case .done:
            self.titleContent.text = "Debat selesai,"
            self.subtitleContent.text = "Inilah hasilnya:"
            self.headerTantanganView.configureType(type: .done)
            self.containerHeader.backgroundColor = #colorLiteral(red: 0.3294117647, green: 0.2549019608, blue: 0.6, alpha: 1)
            self.lblHeader.text = "DONE"
            self.imageContent.image = #imageLiteral(resourceName: "doneMask")
            self.containerDebatDone.isHidden = false
            self.btnTerima.backgroundColor = #colorLiteral(red: 1, green: 0.5569574237, blue: 0, alpha: 1)
            self.btnImageTerima.image = #imageLiteral(resourceName: "outlineDebateDone24PxWhite")
            self.btnTerima.setTitle("LIHAT DEBAT", for: UIControlState())
            self.containerAcceptChallenge.isHidden = false
        case .soon:
            self.titleContent.text = "Siap-siap!"
            self.subtitleContent.text = "Debat akan berlangsung \(2) hari lagi!"
            self.headerTantanganView.configureType(type: .soon)
            self.containerHeader.backgroundColor = #colorLiteral(red: 0, green: 0.6352775693, blue: 0.9890542626, alpha: 1)
            self.lblHeader.text = "COMING SOON"
            self.imageContent.image = #imageLiteral(resourceName: "comingSoonMask")
        default:
            break
        }
    }
}
