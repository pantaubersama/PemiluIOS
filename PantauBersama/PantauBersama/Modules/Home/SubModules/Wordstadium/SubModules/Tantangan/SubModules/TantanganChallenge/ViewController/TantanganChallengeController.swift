//
//  OpenChallengeController.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 12/02/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Common
import RxDataSources

class TantanganChallengeController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var btnNext: ImageButton!
    private let disposeBag = DisposeBag()
    private var statusKajian: Bool = false
    private var nameKajian: String? = nil
    private var statusPernyataan: Bool = false
    private var contentPernyataan: String? = nil
    private var statusDateTime: Bool = false
    private var date: String? = nil
    private var time: String? = nil
    private var statusSaldo: Bool = false
    private var saldo: String? = nil
    private var link: String? = nil
    private var statusDebat: Bool = false
    private var headerView: HeaderTantanganView = HeaderTantanganView()
    
    var dataSource: RxTableViewSectionedReloadDataSource<SectionOfTantanganData>!
    var tantanganType: Bool = false // for open
    var viewModel: TantanganChallengeViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = tantanganType ? "Direct challenge" : "Open challenge"
        
        let back = UIBarButtonItem(image: #imageLiteral(resourceName: "back"), style: .plain, target: nil, action: nil)
        navigationItem.leftBarButtonItem = back
        
        tableView.estimatedRowHeight = 77.0
        tableView.delegate = nil
        tableView.dataSource = nil
        tableView.registerReusableCell(TantanganCell.self)
        tableView.registerReusableCell(BidangKajianCell.self)
        tableView.registerReusableCell(PernyataanCell.self)
        tableView.registerReusableCell(DateTimeCell.self)
        tableView.registerReusableCell(SaldoTimeCell.self)
        tableView.registerReusableCell(LawanDebatCell.self)
        tableView.tableHeaderView = headerView
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
        let open = RxTableViewSectionedReloadDataSource<SectionOfTantanganData>(configureCell: { (dataSource, tableView, indexPath, item) -> UITableViewCell in
            switch indexPath.section {
            case 0:
                let cell = tableView.dequeueReusableCell(indexPath: indexPath) as BidangKajianCell
                cell.configureCell(item: BidangKajianCell.Input(viewModel: self.viewModel, status: self.statusKajian, nameKajian: self.nameKajian))
                return cell
            case 1:
                let cell = tableView.dequeueReusableCell(indexPath: indexPath) as PernyataanCell
                cell.configureCell(item: PernyataanCell.Input(viewModel: self.viewModel, status: self.statusPernyataan, content: self.contentPernyataan, link: self.link))
                return cell
            case 2:
                let cell = tableView.dequeueReusableCell(indexPath: indexPath) as DateTimeCell
                cell.configureCell(item: DateTimeCell.Input(viewModel: self.viewModel, status: self.statusDateTime, date: self.date, time: self.time))
                return cell
            case 3:
                let cell = tableView.dequeueReusableCell(indexPath: indexPath) as SaldoTimeCell
                cell.configureCell(item: SaldoTimeCell.Input(viewModel: self.viewModel, status: self.statusSaldo, saldo: self.saldo))
                return cell
            default:
                let cell = UITableViewCell()
                return cell
            }
        })
        
        let direct = RxTableViewSectionedReloadDataSource<SectionOfTantanganData>(configureCell: { (dataSource, tableView, indexPath, item) -> UITableViewCell in
            switch indexPath.section {
            case 0:
                let cell = tableView.dequeueReusableCell(indexPath: indexPath) as BidangKajianCell
                cell.configureCell(item: BidangKajianCell.Input(viewModel: self.viewModel, status: self.statusKajian, nameKajian: self.nameKajian))
                return cell
            case 1:
                let cell = tableView.dequeueReusableCell(indexPath: indexPath) as PernyataanCell
                cell.configureCell(item: PernyataanCell.Input(viewModel: self.viewModel, status: self.statusPernyataan, content: self.contentPernyataan, link: self.link))
                return cell
            case 2:
                let cell = tableView.dequeueReusableCell(indexPath: indexPath) as LawanDebatCell
                cell.configure(item: LawanDebatCell.Input(viewModel: self.viewModel, status: self.statusDebat))
                return cell
            case 3:
                let cell = tableView.dequeueReusableCell(indexPath: indexPath) as DateTimeCell
                cell.configureCell(item: DateTimeCell.Input(viewModel: self.viewModel, status: self.statusDateTime, date: self.date, time: self.time))
                return cell
            case 4:
                let cell = tableView.dequeueReusableCell(indexPath: indexPath) as SaldoTimeCell
                cell.configureCell(item: SaldoTimeCell.Input(viewModel: self.viewModel, status: self.statusSaldo, saldo: self.saldo))
                return cell
            default:
                let cell = UITableViewCell()
                return cell
            }
        })
        
        dataSource = tantanganType ? direct : open
        
        viewModel.output.itemsO
            .drive(tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        tableView.rx.setDelegate(self)
            .disposed(by: disposeBag)
    
        
        back.rx.tap
            .bind(to: viewModel.input.backI)
            .disposed(by: disposeBag)
        
        btnNext.rx.tap
            .bind(to: viewModel.input.btnNextI)
            .disposed(by: disposeBag)
        
        viewModel.output.kajianSelected
            .do(onNext: { [unowned self] (result) in
                switch result {
                case .ok(let id):
                    print("ID: \(id)")
                    self.viewModel.input.kajianI.onNext(false)
                    self.viewModel.input.pernyataanI.onNext(false)
                    self.viewModel.input.lawanDebatI.onNext(true)
                    self.viewModel.input.dateTimeI.onNext(true)
                    self.viewModel.input.saldoI.onNext(true)
                    self.statusKajian = true
                    self.nameKajian = id
                case .cancel:
                    break
                }
            })
            .drive()
            .disposed(by: disposeBag)
        
        viewModel.output.enablePernyataanO
            .do(onNext: { [unowned self] (enable) in
                self.statusPernyataan = enable
            })
            .drive()
            .disposed(by: disposeBag)
        
        viewModel.output.statusPernyataanO
            .do(onNext: { [unowned self] (s) in
                if s.containsInsensitive("Tulis pernyataanmu di sini...") {
                    self.contentPernyataan = nil
                    self.viewModel.input.kajianI.onNext(false)
                    self.viewModel.input.pernyataanI.onNext(false)
                    self.viewModel.input.lawanDebatI.onNext(true)
                    self.viewModel.input.dateTimeI.onNext(true)
                    self.viewModel.input.saldoI.onNext(true)
                } else {
                    self.contentPernyataan = s
                    self.viewModel.input.kajianI.onNext(false)
                    self.viewModel.input.pernyataanI.onNext(false)
                    self.viewModel.input.lawanDebatI.onNext(false)
                    self.viewModel.input.dateTimeI.onNext(false)
                    self.viewModel.input.saldoI.onNext(true)
                }
            })
            .drive()
            .disposed(by: disposeBag)
        
        viewModel.output.statusDateO
            .do(onNext: { [unowned self] (s) in
                self.viewModel.input.kajianI.onNext(false)
                self.viewModel.input.pernyataanI.onNext(false)
                self.viewModel.input.lawanDebatI.onNext(false)
                self.viewModel.input.dateTimeI.onNext(false)
                self.viewModel.input.saldoI.onNext(false)
                self.statusDateTime = false
                self.date = s
            })
            .drive()
            .disposed(by: disposeBag)
        
        viewModel.output.statusTimeO
            .do(onNext: { [unowned self] (s) in
                self.viewModel.input.kajianI.onNext(false)
                self.viewModel.input.pernyataanI.onNext(false)
                self.viewModel.input.lawanDebatI.onNext(false)
                self.viewModel.input.dateTimeI.onNext(false)
                self.viewModel.input.saldoI.onNext(false)
                self.statusDateTime = true
                self.time = s
            })
            .drive()
            .disposed(by: disposeBag)
        
        viewModel.output.saldoTimeO
            .do(onNext: { [unowned self] (s) in
                self.viewModel.input.kajianI.onNext(false)
                self.viewModel.input.pernyataanI.onNext(false)
                self.viewModel.input.lawanDebatI.onNext(false)
                self.viewModel.input.dateTimeI.onNext(false)
                self.viewModel.input.saldoI.onNext(false)
                self.statusSaldo = true
                self.saldo = s
            })
            .drive()
            .disposed(by: disposeBag)
        
        viewModel.output.hintKajianO
            .drive()
            .disposed(by: disposeBag)
        
        viewModel.output.hintPernyataanO
            .drive()
            .disposed(by: disposeBag)
        
        viewModel.output.hintDateTimeO
            .drive()
            .disposed(by: disposeBag)
        
        viewModel.output.hintSaldoO
            .drive()
            .disposed(by: disposeBag)
        
        viewModel.output.hintDebatO
            .drive()
            .disposed(by: disposeBag)
        
        
        viewModel.output.pernyataanLink
            .do(onNext: { (result) in
                switch result {
                case .cancel: break
                case .ok(let url):
                    self.viewModel.input.kajianI.onNext(false)
                    self.viewModel.input.pernyataanI.onNext(false)
                    self.viewModel.input.lawanDebatI.onNext(false)
                    self.viewModel.input.dateTimeI.onNext(false)
                    self.viewModel.input.saldoI.onNext(true)
                    self.statusPernyataan = true
                    self.link = url
                }
            })
            .drive()
            .disposed(by: disposeBag)
        
        viewModel.output.cancelLinkO
            .do(onNext: { [unowned self] (_) in
                if self.contentPernyataan != nil {
                    self.viewModel.input.kajianI.onNext(false)
                    self.viewModel.input.pernyataanI.onNext(false)
                    self.viewModel.input.lawanDebatI.onNext(false)
                    self.viewModel.input.dateTimeI.onNext(false)
                    self.viewModel.input.saldoI.onNext(true)
                    self.statusPernyataan = true
                } else {
                    self.viewModel.input.kajianI.onNext(false)
                    self.viewModel.input.pernyataanI.onNext(false)
                    self.viewModel.input.lawanDebatI.onNext(true)
                    self.viewModel.input.dateTimeI.onNext(true)
                    self.viewModel.input.saldoI.onNext(true)
                    self.statusPernyataan = false
                }
                self.link = nil
            })
            .drive()
            .disposed(by: disposeBag)
        
        viewModel.output.enableNextO
            .do(onNext: { [unowned self] (enable) in
                self.btnNext.backgroundColor = enable ? #colorLiteral(red: 1, green: 0.5569574237, blue: 0, alpha: 1) : #colorLiteral(red: 0.9253990054, green: 0.9255540371, blue: 0.925378561, alpha: 1)
            })
            .drive(btnNext.rx.isEnabled)
            .disposed(by: disposeBag)
        
        viewModel.output.meO
            .do(onNext: { [unowned self] (user) in
                self.tantanganType ? self.headerView.configure(data: user, type: .direct)
                    : self.headerView.configure(data: user, type: .open)
            })
            .drive()
            .disposed(by: disposeBag)
        
        viewModel.output.btnNextO
            .drive()
            .disposed(by: disposeBag)
        
        switch tantanganType {
        case false:
            viewModel.input.kajianI.onNext(false)
            viewModel.input.pernyataanI.onNext(true)
            viewModel.input.dateTimeI.onNext(true)
            viewModel.input.saldoI.onNext(true)
        case true:
            viewModel.input.kajianI.onNext(false)
            viewModel.input.pernyataanI.onNext(true)
            viewModel.input.lawanDebatI.onNext(true)
            viewModel.input.dateTimeI.onNext(true)
            viewModel.input.saldoI.onNext(true)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.configure(with: .white)
    }
    
}

extension TantanganChallengeController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch tantanganType {
        case false:
            switch indexPath.section {
            case 0:
                return 110.0
            case 1:
                if link != nil {
                    return 219.0 + 75.0 - 24.0
                } else {
                    return 219.0
                }
            case 2:
                return 175.0
            case 3:
                return 140.0
            default:
                return 77.0
            }
        case true:
            switch indexPath.section {
            case 0:
                return 110.0
            case 1:
                if link != nil {
                    return 219.0 + 75.0
                } else {
                    return 219.0
                }
            case 2:
                return 181.0
            case 3:
                return 175.0
            case 4:
                return 140.0
            default:
                return 77.0
            }
        }
    }
    
}
