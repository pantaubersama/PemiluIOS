//
//  CatatanPilpresController.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 23/01/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import RxSwift
import RxCocoa
import Common

class CatatanPilpresController: UIViewController {
    
    @IBOutlet weak var lblPreference: Label!
    @IBOutlet weak var containerPaslonSatu: UIView!
    @IBOutlet weak var containerPaslonDua: UIView!
    @IBOutlet weak var buttonPaslonSatu: Button!
    @IBOutlet weak var buttonPaslonDua: Button!
    @IBOutlet weak var buttonNotPreference: Button!
    
    @IBOutlet weak var iconPreference: CircularUIImageView!
    @IBOutlet weak var lblKecenderungan: Label!
    @IBOutlet weak var lblPercentage: UILabel!
    @IBOutlet weak var lblUser: Label!
    
    private var buttonGroup: [UIButton] = []
    private var containerGroup: [UIView] = []
    
    var viewModel: CatatanPilpresViewModel!
    private let disposeBag: DisposeBag = DisposeBag()
    
    convenience init(viewModel: CatatanPilpresViewModel) {
        self.init()
        self.viewModel = viewModel
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        buttonGroup = [buttonPaslonSatu, buttonPaslonDua,buttonNotPreference]
        containerGroup = [containerPaslonSatu, containerPaslonDua]
        
        buttonPaslonSatu.rx.tap
            .map {(1)}
            .do(onNext: { [weak self] (_) in
                self?.viewModel.input.notePreferenceI.onNext(("(Jokowi - Ma'ruf)"))
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
        
            buttonNotPreference.rx.tap
                .map {(3)}
                .do(onNext: { [weak self] (_) in
                    self?.viewModel.input.notePreferenceI.onNext(("(belum menentukan pilihan)"))
                })
                .bind(to: viewModel.input.notePreferenceValueI)
                .disposed(by: disposeBag)
        
            viewModel.output.totalResultO
                .drive(onNext: { [weak self] (response) in
                    guard let `self` = self else { return }
                    let preference = response.teams.max { $0.percentage?.isLess(than: $1.percentage ?? 0.0) ?? false }
                    if let avatarUrl = preference?.team.avatar {
                        self.iconPreference.af_setImage(withURL: URL(string: avatarUrl)!)
                    }
                    self.lblKecenderungan.text = "Total Kecenderungan\(response.meta.quizzes.finished) dari \(response.meta.quizzes.total) Quiz"
                    self.lblUser.text = "\(response.user.fullName ?? "") lebih suka jawaban dari Paslon no \(preference?.team.id ?? 0)"
                    self.lblPercentage.text = String(format: "%.0f", preference?.percentage ?? 0.0) + "% \(preference?.team.title ?? "")"
                    
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
                            self.lblPreference.text = "(Jokowi - Ma'ruf)"
                        case 2:
                            self.buttonPaslonDua.layer.borderColor = Color.orange_warm.cgColor
                            self.buttonPaslonDua.setTitleColor(Color.orange_warm, for: .normal)
                            self.containerPaslonDua.layer.borderColor = Color.orange_warm.cgColor
                            self.lblPreference.text = "(Prabowo - Sandi)"
                        case 3:
                            self.buttonNotPreference.layer.borderColor = Color.orange_warm.cgColor
                            self.buttonNotPreference.setTitleColor(Color.orange_warm, for: .normal)
                            self.lblPreference.text = "(belum menentukan pilihan)"
                        default: break
                        }
                    }
                    
                })
                .disposed(by: disposeBag)

            viewModel.output.notePreferenceO
                .drive(onNext: { [weak self] (s) in
                    guard let `self` = self else { return }
                    self.lblPreference.text = s
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
                        self.buttonNotPreference.layer.borderColor = Color.orange_warm.cgColor
                        self.buttonNotPreference.setTitleColor(Color.orange_warm, for: .normal)
                    default: break
                    }
                })
                .disposed(by: disposeBag)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.input.viewWillAppearI.onNext(())
    }
    
}

extension CatatanPilpresController {
        private func resetButton() {
            buttonGroup.forEach { (b) in
                b.layer.borderColor = Color.grey_four.cgColor
                b.setTitleColor(Color.grey_four, for: .normal)
            }
            containerGroup.forEach { (v) in
                v.layer.borderColor = Color.grey_four.cgColor
            }
        }
}
