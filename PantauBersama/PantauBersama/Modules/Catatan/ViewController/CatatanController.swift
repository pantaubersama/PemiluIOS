//
//  CatatanController.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 04/01/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Common

class CatatanController: UIViewController {
    
    var viewModel: CatatanViewModel!
    @IBOutlet weak var iconPreference: UIImageView!
    @IBOutlet weak var labelPreference: Label!
    @IBOutlet weak var labelPercentage: Label!
    @IBOutlet weak var buttonPaslonSatu: Button!
    @IBOutlet weak var buttonPaslonDua: Button!
    @IBOutlet weak var buttonGolput: Button!
    @IBOutlet weak var notePreference: Label!
    @IBOutlet weak var containerPaslonSatu: UIView!
    @IBOutlet weak var containerPaslonDua: UIView!
    private var buttonGroup: [Button] = []
    private var containerGroup: [UIView] = []
    @IBOutlet weak var updateButton: Button!
    
    private let disposeBag: DisposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        buttonGroup = [buttonPaslonSatu, buttonPaslonDua, buttonGolput]
        containerGroup = [containerPaslonSatu, containerPaslonDua]
        
        navigationController?.navigationBar.configure(with: .white)
        title = "Catatan Pilihanku"
        let back = UIBarButtonItem(image: #imageLiteral(resourceName: "back"), style: .plain, target: nil, action: nil)
        navigationItem.leftBarButtonItem = back
        
        back.rx.tap
            .bind(to: viewModel.input.backI)
            .disposed(by: disposeBag)
        
        buttonPaslonSatu.rx.tap
            .map {(1)}
            .do(onNext: { [weak self] (_) in
                self?.viewModel.input.notePreferenceI.onNext(("(Jokowi - Makruf)"))
            })
            .bind(to: viewModel.input.notePreferenceValueI)
            .disposed(by: disposeBag)
        
        buttonPaslonDua.rx.tap
            .map {(2)}
            .do(onNext: { [weak self] (_) in
                self?.viewModel.input.notePreferenceI.onNext(("(Prabowo - Sandi)"))
            })
            .bind(to: viewModel.input.notePreferenceValueI)
            .disposed(by: disposeBag)
        
        buttonGolput.rx.tap
            .map {(3)}
            .do(onNext: { [weak self] (_) in
                self?.viewModel.input.notePreferenceI.onNext(("(belum menentukan pilihan)"))
            })
            .bind(to: viewModel.input.notePreferenceValueI)
            .disposed(by: disposeBag)
        
        updateButton.rx.tap
            .bind(to: viewModel.input.updateI)
            .disposed(by: disposeBag)
        
        viewModel.output.totalResultO
            .drive(onNext: { [weak self] (response) in
                guard let `self` = self else { return }
                let preference = response.teams.max { $0.percentage?.isLess(than: $1.percentage ?? 0.0) ?? false }
                if let avatarUrl = preference?.team.avatar {
                    self.iconPreference.af_setImage(withURL: URL(string: avatarUrl)!)
                }
                self.labelPreference.text = "\(response.meta.quizzes.finished) dari \(response.meta.quizzes.total) Kuis"
                self.labelPercentage.text = "\(Double(preference?.percentage ?? 0.0))% (\(preference?.team.title ?? ""))"
            })
            .disposed(by: disposeBag)
        
        viewModel.output.userDataO
            .drive(onNext: { [weak self] (response) in
                guard let `self` = self else { return }
                if let votePreference = response.user.votePreference {
                    switch votePreference {
                    case 1:
                        self.buttonPaslonSatu.layer.borderColor = Color.orange_warm.cgColor
                        self.buttonPaslonSatu.setTitleColor(Color.orange_warm, for: .normal)
                        self.containerPaslonSatu.layer.borderColor = Color.orange_warm.cgColor
                        self.notePreference.text = "(Jokowi - Makruf)"
                    case 2:
                        self.buttonPaslonDua.layer.borderColor = Color.orange_warm.cgColor
                        self.buttonPaslonDua.setTitleColor(Color.orange_warm, for: .normal)
                        self.containerPaslonDua.layer.borderColor = Color.orange_warm.cgColor
                        self.notePreference.text = "(Prabowo - Sandi)"
                    case 3:
                        self.buttonGolput.layer.borderColor = Color.orange_warm.cgColor
                        self.buttonGolput.setTitleColor(Color.orange_warm, for: .normal)
                        self.notePreference.text = "(belum menentukan pilihan)"
                    default: break
                    }
                }
                
            })
            .disposed(by: disposeBag)
        
        viewModel.output.notePreferenceO
            .drive(onNext: { [weak self] (s) in
                guard let `self` = self else { return }
                self.notePreference.text = s
            })
            .disposed(by: disposeBag)
        
        viewModel.output.notePreferenceValueO
            .drive(onNext: { [weak self] (i) in
                guard let `self` = self else { return }
                self.resetButton()
                switch i {
                case 1:
                    self.buttonPaslonSatu.layer.borderColor = Color.orange_warm.cgColor
                    self.buttonPaslonSatu.setTitleColor(Color.orange_warm, for: .normal)
                    self.containerPaslonSatu.layer.borderColor = Color.orange_warm.cgColor
                case 2:
                    self.buttonPaslonDua.layer.borderColor = Color.orange_warm.cgColor
                    self.buttonPaslonDua.setTitleColor(Color.orange_warm, for: .normal)
                    self.containerPaslonDua.layer.borderColor = Color.orange_warm.cgColor
                case 3:
                    self.buttonGolput.layer.borderColor = Color.orange_warm.cgColor
                    self.buttonGolput.setTitleColor(Color.orange_warm, for: .normal)
                default: break
                }
            })
            .disposed(by: disposeBag)
        
        viewModel.output.enableO
            .do(onNext: { [weak self] (enable) in
                guard let `self` = self else { return }
                self.updateButton.backgroundColor = enable ? Color.primary_red : Color.grey_one
            })
            .drive(updateButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        viewModel.output.updateO
            .drive()
            .disposed(by: disposeBag)
        
        viewModel.output.errorTracker
            .drive(onNext: { [weak self] (e) in
                guard let alert = UIAlertController.alert(with: e) else { return }
                self?.navigationController?.present(alert, animated: true, completion: nil)
            })
            .disposed(by: disposeBag)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.input.viewWillAppearI.onNext(())
    }
    
}


extension CatatanController {
    
    private func resetButton() {
        buttonGroup.forEach { (b) in
            b.borderColor = Color.grey_five
            b.setTitleColor(Color.grey_five, for: .normal)
        }
        containerGroup.forEach { (v) in
            v.layer.borderColor = Color.grey_five.cgColor
        }
    }
    
}
