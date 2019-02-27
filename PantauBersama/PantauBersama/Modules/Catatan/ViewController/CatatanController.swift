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
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var lblQuizResult: Label!
    @IBOutlet weak var lblPreferenceUser: Label!
    @IBOutlet weak var lblPreferenceResult: UILabel!
    @IBOutlet weak var iconPreference: CircularUIImageView!
    
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
        
        // MARK
        // User Response
        viewModel.output.userDataO
            .drive(onNext: { [weak self] (response) in
                guard let `self` = self else { return }
            })
            .disposed(by: disposeBag)
        
        // MARK
        // Total Result
        viewModel.output.totalResultO
            .drive(onNext: { [weak self] (response) in
                guard let `self` = self else { return }
                let preference = response.teams.max { $0.percentage?.isLess(than: $1.percentage ?? 0.0) ?? false }
                let trendString: String? = String(format: "%.0f", preference?.percentage ?? 0.0)
                let randomResponse = response.teams.randomElement()
                if trendString == "50" {
                    if let avatarUrl = randomResponse?.team.avatar {
                        self.iconPreference.af_setImage(withURL: URL(string: avatarUrl)!)
                    }
                    self.lblQuizResult.text = "Total Kecenderungan \(response.meta.quizzes.finished) dari \(response.meta.quizzes.total) Quiz"
                    self.lblPreferenceUser.text = "\(response.user.fullName ?? "") lebih suka jawaban dari Paslon no \(randomResponse?.team.id ?? 0)"
                    self.lblPreferenceResult.text = String(format: "%.0f", randomResponse?.percentage ?? 0.0) + "% \(randomResponse?.team.title ?? "")"
                } else if trendString == "0" {
                    if let avatarUrl = randomResponse?.team.avatar {
                        self.iconPreference.af_setImage(withURL: URL(string: avatarUrl)!)
                    }
                    self.lblQuizResult.text = "Total Kecenderungan \(response.meta.quizzes.finished) dari \(response.meta.quizzes.total) Quiz"
                    self.lblPreferenceUser.text = "\(response.user.fullName ?? "") lebih suka jawaban dari Paslon no \(randomResponse?.team.id ?? 0)"
                    self.lblPreferenceResult.text = String(format: "%.0f", randomResponse?.percentage ?? 0.0) + "% \(randomResponse?.team.title ?? "")"
                } else {
                    if let avatarUrl = preference?.team.avatar {
                        self.iconPreference.af_setImage(withURL: URL(string: avatarUrl)!)
                    }
                    self.lblQuizResult.text = "Total Kecenderungan \(response.meta.quizzes.finished) dari \(response.meta.quizzes.total) Quiz"
                    self.lblPreferenceUser.text = "\(response.user.fullName ?? "") lebih suka jawaban dari Paslon no \(preference?.team.id ?? 0)"
                    self.lblPreferenceResult.text = String(format: "%.0f", preference?.percentage ?? 0.0) + "% \(preference?.team.title ?? "")"
                }
            })
            .disposed(by: disposeBag)
        
        
        
//        viewModel.output.enableO
//            .do(onNext: { [weak self] (enable) in
//                guard let `self` = self else { return }
//                self.btnUpdate.backgroundColor = enable ? Color.primary_red : Color.grey_one
//            })
//            .drive(btnUpdate.rx.isEnabled)
//            .disposed(by: disposeBag)
        
       viewModel.output.updateO
            .drive()
            .disposed(by: disposeBag)
        
        viewModel.output.partyItemsO
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
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell() as PartyCaraouselCell
            cell.configureCell(item: PartyCaraouselCell.Input(viewModel: self.viewModel))
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
            return 275.0
        case 667:
            return 360.0 // case for sreen iphone 6s
        default:
            return 360.0
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
