//
//  TooltipView.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 12/02/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import UIKit
import Common
import RxSwift
import RxCocoa
import Networking

class TooltipView: UIViewController {
    
    @IBOutlet weak var containerChallenge: RoundView!
    @IBOutlet weak var btnChallenge: UIButton!
    @IBOutlet weak var lblChallenge: Label!
    @IBOutlet weak var containerDebatDone: RoundView!
    @IBOutlet weak var btnDebatDone: UIButton!
    @IBOutlet weak var lblDebatDone: Label!
    @IBOutlet weak var containerComingSoon: RoundView!
    @IBOutlet weak var btnComingSoon: UIButton!
    @IBOutlet weak var lblComingSoon: Label!
    @IBOutlet weak var containerDebatLive: RoundView!
    @IBOutlet weak var btnDebatLive: UIButton!
    @IBOutlet weak var lblDebatLive: Label!
    @IBOutlet weak var containerCreate: RoundView!
    @IBOutlet weak var btnCreate: UIButton!
    
    var viewModel: TooltipViewModel!
    var type: LiniType!
    private let disposeBag: DisposeBag = DisposeBag()
    
    private let tapChallenge: UITapGestureRecognizer = UITapGestureRecognizer()
    private let tapDebat: UITapGestureRecognizer = UITapGestureRecognizer()
    private let tapComing: UITapGestureRecognizer = UITapGestureRecognizer()
    private let tapDebatLive: UITapGestureRecognizer = UITapGestureRecognizer()
    private let tapCreate: UITapGestureRecognizer = UITapGestureRecognizer()
    private let tapCancel: UITapGestureRecognizer = UITapGestureRecognizer()
    
    convenience init(type: LiniType) {
        self.init()
        self.type = type
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if self.type == .personal {
            lblChallenge.text = "My Challenge"
            lblDebatDone.text = "My Debat Done"
            lblComingSoon.text = "My Debat Coming Soon"
            lblDebatLive.text = "In Proggress"
        } else {
            lblChallenge.text = "Challenge"
            lblDebatDone.text = "Debat Done"
            lblComingSoon.text = "Coming Soon"
            lblDebatLive.text = "Debat Live"
        }
        
        btnChallenge.rx.tap
            .bind(to: viewModel.input.challengeI)
            .disposed(by: disposeBag)
        
        containerChallenge.addGestureRecognizer(tapChallenge)
        containerChallenge.isUserInteractionEnabled = true
        tapChallenge.rx.event
            .mapToVoid()
            .bind(to: viewModel.input.challengeI)
            .disposed(by: disposeBag)
        
        btnDebatDone.rx.tap
            .bind(to: viewModel.input.debatDoneI)
            .disposed(by: disposeBag)
        
        containerDebatDone.addGestureRecognizer(tapDebat)
        containerDebatDone.isUserInteractionEnabled = true
        tapDebat.rx.event
            .mapToVoid()
            .bind(to: viewModel.input.debatDoneI)
            .disposed(by: disposeBag)
        
        btnComingSoon.rx.tap
            .bind(to: viewModel.input.comingSoonI)
            .disposed(by: disposeBag)
        
        containerComingSoon.addGestureRecognizer(tapComing)
        containerComingSoon.isUserInteractionEnabled = true
        tapComing.rx.event
            .mapToVoid()
            .bind(to: viewModel.input.comingSoonI)
            .disposed(by: disposeBag)
        
        btnDebatLive.rx.tap
            .bind(to: viewModel.input.debatLiveI)
            .disposed(by: disposeBag)
        
        containerDebatLive.addGestureRecognizer(tapDebatLive)
        containerDebatLive.isUserInteractionEnabled = true
        tapDebatLive.rx.event
            .mapToVoid()
            .bind(to: viewModel.input.debatLiveI)
            .disposed(by: disposeBag)
        
        btnCreate.rx.tap
            .bind(to: viewModel.input.createTantanganI)
            .disposed(by: disposeBag)
        
        containerCreate.addGestureRecognizer(tapCreate)
        containerCreate.isUserInteractionEnabled = true
        tapCreate.rx.event
            .mapToVoid()
            .bind(to: viewModel.input.createTantanganI)
            .disposed(by: disposeBag)
        
        view.addGestureRecognizer(tapCancel)
        view.isUserInteractionEnabled = true
        tapCancel.rx.event
            .mapToVoid()
            .bind(to: viewModel.input.cancelI)
            .disposed(by: disposeBag)
        
        viewModel.output.actionsSelected
            .drive()
            .disposed(by: disposeBag)
    }
    
    
}
