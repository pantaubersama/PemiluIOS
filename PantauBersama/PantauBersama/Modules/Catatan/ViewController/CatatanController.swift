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
import Networking

class CatatanController: UIViewController {
    
    var viewModel: CatatanViewModel!
    @IBOutlet weak var btnUpdate: Button!
    @IBOutlet weak var tableView: UITableView!
    
    private var focusPaslon: Int? = nil
    private var focusPaty: Int? = nil
    private var preferenceQuiz: String? = nil
    private var paslonUrl: String? = nil
    private var preferenceUser: String? = nil
    private var preference: String? = nil
    
    private let disposeBag: DisposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        navigationController?.navigationBar.configure(with: .white)
        title = "Catatan Pilihanku"
        let back = UIBarButtonItem(image: #imageLiteral(resourceName: "back"), style: .plain, target: nil, action: nil)
        navigationItem.leftBarButtonItem = back
        
        
        // MARK
        // Register tableview
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        tableView.registerReusableCell(PaslonCaraouselCell.self)
        tableView.registerReusableCell(PartyCaraouselCell.self)
        
        back.rx.tap
            .bind(to: viewModel.input.backI)
            .disposed(by: disposeBag)
        
        btnUpdate.rx.tap
            .bind(to: viewModel.input.updateI)
            .disposed(by: disposeBag)
        
        // MARK
        // User Response
        viewModel.output.userDataO
            .drive(onNext: { [weak self] (response) in
                guard let `self` = self else { return }
                if let paslon = response.user.votePreference {
                    self.focusPaslon = paslon
                }
                if let party = response.user.politicalParty?.number {
                    self.focusPaty = party
                }
            })
            .disposed(by: disposeBag)
        
        // MARK
        // Total Result
        viewModel.output.totalResultO
            .do(onNext: { [weak self] (response) in
                guard let `self` = self else { return }
                let preference = response.teams.max { $0.percentage?.isLess(than: $1.percentage ?? 0.0) ?? false }
                let trendString: String? = String(format: "%.0f", preference?.percentage ?? 0.0)
                let randomResponse = response.teams.randomElement()
                if trendString == "50" {
                    if let avatarUrl = randomResponse?.team.avatar {
                        self.paslonUrl = avatarUrl
                    }
                    self.preferenceQuiz = "Total Kecenderungan \(response.meta.quizzes.finished) dari \(response.meta.quizzes.total) Quiz"
                    self.preferenceUser = "\(response.user.fullName ?? "") lebih suka jawaban dari Paslon no \(randomResponse?.team.id ?? 0)"
                    self.preference = String(format: "%.0f", randomResponse?.percentage ?? 0.0) + "% \(randomResponse?.team.title ?? "")"
                } else if trendString == "0" {
                    if let avatarUrl = randomResponse?.team.avatar {
                        self.paslonUrl = avatarUrl
                    }
                    self.preferenceQuiz = "Total Kecenderungan \(response.meta.quizzes.finished) dari \(response.meta.quizzes.total) Quiz"
                    self.preferenceUser = "\(response.user.fullName ?? "") lebih suka jawaban dari Paslon no \(randomResponse?.team.id ?? 0)"
                    self.preference = String(format: "%.0f", randomResponse?.percentage ?? 0.0) + "% \(randomResponse?.team.title ?? "")"
                } else {
                    if let avatarUrl = preference?.team.avatar {
                        self.paslonUrl = avatarUrl
                    }
                    self.preferenceQuiz = "Total Kecenderungan \(response.meta.quizzes.finished) dari \(response.meta.quizzes.total) Quiz"
                    self.preferenceUser = "\(response.user.fullName ?? "") lebih suka jawaban dari Paslon no \(preference?.team.id ?? 0)"
                    self.preference = String(format: "%.0f", preference?.percentage ?? 0.0) + "% \(preference?.team.title ?? "")"
                }
                DispatchQueue.main.async(execute: {
                    self.tableView.reloadData()
                })
            })
            .drive()
            .disposed(by: disposeBag)
        
        
        
        viewModel.output.enableO
            .do(onNext: { [weak self] (enable) in
                guard let `self` = self else { return }
                self.btnUpdate.backgroundColor = enable ? Color.primary_red : Color.grey_one
            })
            .drive(btnUpdate.rx.isEnabled)
            .disposed(by: disposeBag)
        
       viewModel.output.updateO
            .drive()
            .disposed(by: disposeBag)
        
        viewModel.output.partyItemsO
            .drive()
            .disposed(by: disposeBag)
        
        viewModel.output.notePreferenceValueO
            .drive()
            .disposed(by: disposeBag)
        
        viewModel.output.partyPreferenceValueO
            .drive()
            .disposed(by: disposeBag)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.input.viewWillAppearI.onNext(())
    }
    
}

extension CatatanController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell() as PaslonCaraouselCell
            cell.configureCell(item: PaslonCaraouselCell.Input(focus: self.focusPaslon ?? 0, viewModel: self.viewModel, preferenceQuiz: self.preferenceQuiz ?? "", paslonUrl: self.paslonUrl ?? "", preferenceUser: self.preferenceUser ?? "", preference: self.preference ?? ""))
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell() as PartyCaraouselCell
            cell.configureCell(item: PartyCaraouselCell.Input(viewModel: self.viewModel, focus: self.focusPaty ?? 0))
            return cell
        default:
            let cell = UITableViewCell()
            return cell
        }
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch UIScreen.main.bounds.height {
        case 568:
            return 360.0
        case 667:
            return 460.0 // case for sreen iphone 6s
        default:
            return 460.0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50.0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        switch section {
        case 0:
            let view = HeaderCatatanView()
            view.lblContent.text = "Siapakah yang saat ini cocok dengan pilihan kamu?"
            return view
        case 1:
            let view = HeaderCatatanView()
            view.lblContent.text = "Partai mana yang cocok dengan pilihan kamu?"
            return view
        default:
            let view = UIView()
            return view
        }
    }
}
