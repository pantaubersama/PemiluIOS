//
//  WordstadiumListViewController.swift
//  PantauBersama
//
//  Created by wisnu bhakti on 15/02/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

class WordstadiumListViewController: UITableViewController {

    var viewModel: WordstadiumListViewModel!
    private let disposeBag: DisposeBag = DisposeBag()
    lazy var tableHeaderView = WordstadiumListHeaderView()
    
    var rControl : UIRefreshControl?
    
    var dataSource: RxTableViewSectionedReloadDataSource<SectionWordstadium>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.configure(with: .white)
        let back = UIBarButtonItem(image: #imageLiteral(resourceName: "back"), style: .plain, target: nil, action: nil)
        navigationItem.leftBarButtonItem = back
        
        tableView.registerReusableCell(WordstadiumItemViewCell.self)
        tableView.delegate = nil
        tableView.dataSource = nil
        tableView.estimatedRowHeight = 44.0
        tableView.separatorStyle = .none
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        tableView.tableFooterView = UIView()
        tableView.refreshControl = UIRefreshControl()
        tableView.tableHeaderView = tableHeaderView
        
        back.rx.tap
            .bind(to: viewModel.input.backTriggger)
            .disposed(by: disposeBag)

        tableView.rx
            .setDelegate(self)
            .disposed(by: disposeBag)
        
        dataSource = RxTableViewSectionedReloadDataSource<SectionWordstadium>(
            configureCell: { (dataSource, tableView, indexPath, item) in
                let wordstadium = dataSource.sectionModels[indexPath.section]
                
                let cell = tableView.dequeueReusableCell(indexPath: indexPath) as WordstadiumItemViewCell
                cell.configureCell(item: WordstadiumItemViewCell.Input(type: wordstadium.itemType, wordstadium: wordstadium.items[indexPath.row]))
                return cell
        })
        
        viewModel.output.items
            .do(onNext: { (items) in
                switch items[0].itemType {
                case .comingsoon:
                    self.title = "Debat: Coming Soon"
                    self.tableHeaderView.config(description: "Jangan lewatkan daftar debat yang akan segera berlangsung. Catat jadwalnya, yaa.")
                case .done:
                    self.title = "Debat: Done"
                    self.tableHeaderView.config(description: "Berikan komentar dan appresiasi pada debat-debat yang sudah selesai. Daftarnya ada di bawah ini:")
                case .challenge:
                    self.title = "Challenge"
                    self.tableHeaderView.config(description: "Daftar Open Challenge yang bisa diikuti. Pilih debat mana yang kamu ingin ambil tantangannya. Be truthful and gentle! ;)")
                case .privateComingsoon:
                    self.title = "My Debat: Coming Soon"
                    self.tableHeaderView.config(description: "Jangan lewatkan daftar debat yang akan segera berlangsung. Catat jadwalnya, yaa.")
                case .privateDone:
                    self.title = "My Debat: Done"
                    self.tableHeaderView.config(description: "Berikan komentar dan appresiasi pada debat-debat yang sudah selesai. Daftarnya ada di bawah ini:")
                case .privateChallenge:
                    self.title = "My Challenge"
                    self.tableHeaderView.config(description: "Daftar tantangan yang kamu buat, yang kamu ikuti dan tantangan dari orang lain buat kamu ditampilkan semua di sini.")
                case .inProgress:
                    self.title = "Challenge in Progress"
                    self.tableHeaderView.config(description: "Daftar tantangan yang perlu respon dan perlu konfirmasi ditampilkan semua disini. Jangan sampai terlewatkan, yaa.")
                case .live:
                    self.title = "LIVE NOW"
                    self.tableHeaderView.config(description: "Ini daftar debat yang sedang berlangsung. Yuk, pantau bersama!")
                }
            })
            .drive(tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)


    }

    // TODO: for testing purpose
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let wordstadium = dataSource.sectionModels[indexPath.section]
        
        switch wordstadium.itemType {
        case .privateChallenge, .challenge, .inProgress:
            guard let navigationController = self.navigationController else { return }
            let challengeCoordinator = ChallengeCoordinator(navigationController: navigationController, type: wordstadium.items[indexPath.row].type)
            challengeCoordinator
                .start()
                .subscribe()
                .disposed(by: disposeBag)
        case .privateComingsoon, .comingsoon:
            guard let navigationController = self.navigationController else { return }
            let challengeCoordinator = ChallengeCoordinator(navigationController: navigationController, type: .soon)
            challengeCoordinator
                .start()
                .subscribe()
                .disposed(by: disposeBag)
        case .privateDone, .done:
            guard let navigationController = self.navigationController else { return }
            let challengeCoordinator = ChallengeCoordinator(navigationController: navigationController, type: .done)
            challengeCoordinator
                .start()
                .subscribe()
                .disposed(by: disposeBag)
        case .live:
            guard let navigationController = self.navigationController else { return }
            let liveDebatCoordinator = LiveDebatCoordinator(navigationController: navigationController, viewType: .watch)
            liveDebatCoordinator
                .start()
                .subscribe()
                .disposed(by: disposeBag)
        }
    }
    
}
