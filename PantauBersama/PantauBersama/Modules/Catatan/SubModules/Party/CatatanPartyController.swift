//
//  CatatanPartyController.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 23/01/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import RxSwift
import RxCocoa
import Common

class CatatanPartyController: UIViewController {
    
    @IBOutlet weak var lblPreferenceParty: Label!
    @IBOutlet weak var tableView: UITableView!
    private var footerView: NotePreferenceView!
    
    var viewModel: CatatanPartyViewModel!
    private let disposeBag = DisposeBag()
    private var state: Bool = false
    
    convenience init(viewModel: CatatanPartyViewModel) {
        self.init()
        self.viewModel = viewModel
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.registerReusableCell(PartyCell.self)
        tableView.rowHeight = 60.0
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        footerView = NotePreferenceView()
        tableView.tableFooterView = footerView
        tableView.delegate = nil
        tableView.dataSource = nil
        
        viewModel.output.itemsO
            .drive(tableView.rx.items) { tableView, row, item in
                guard let cell = tableView.dequeueReusableCell(withIdentifier: item.reuseIdentifier) else {
                    return UITableViewCell()
                }
                cell.tag = row
                item.configure(cell: cell)
                return cell
            }
            .disposed(by: disposeBag)
        
        tableView.rx.contentOffset
            .distinctUntilChanged()
            .flatMapLatest { (offset) -> Observable<Void> in
                if offset.y > self.tableView.contentSize.height -
                    (self.tableView.frame.height * 2) {
                    return Observable.just(())
                } else {
                    return Observable.empty()
                }
            }
            .bind(to: viewModel.input.nextTriggerI)
            .disposed(by: disposeBag)
        
        tableView.rx.itemSelected
            .bind(to: viewModel.input.itemSelectedI)
            .disposed(by: disposeBag)
        
        viewModel.output.itemSelectedO
            .do(onNext: { [weak self] (political) in
                self?.lblPreferenceParty.text = "(\(political.name))"
                self?.footerView.buttonNotPreference.backgroundColor = Color.grey_two
                self?.footerView.buttonNotPreference.setTitleColor(Color.grey_four, for: .normal)
                self?.state = false
                self?.viewModel.input.notPreferenceI.onNext((political.id))
            })
            .drive()
            .disposed(by: disposeBag)
        
        viewModel.output.userDataO
            .drive(onNext: { [weak self] (response) in
                guard let `self` = self else { return }
                let user = response.user
                self.lblPreferenceParty.text = user.politicalParty?.name
                // check state number selected cell
                // - 1 for indexes array
                if user.politicalParty != nil {
                    if let number = user.politicalParty?.number {
                        self.tableView.selectRow(at: IndexPath(row: number - 1 , section: 0), animated: false, scrollPosition: .none)
                    }
                } else {
                    self.footerView.buttonNotPreference.backgroundColor = Color.orange_warm
                    self.footerView.buttonNotPreference.setTitleColor(Color.primary_white, for: .normal)
                    self.lblPreferenceParty.text = "(Belum menentukan pilihan)"
                }
            })
            .disposed(by: disposeBag)
        
        footerView.buttonNotPreference.rx.tap.scan(self.state) { lastState, newValue in return !lastState
            }.subscribe(onNext: { [weak self] (value) in
                guard let `self` = self else { return }
                self.footerView.buttonNotPreference.backgroundColor = value ? Color.orange_warm : Color.grey_two
                let color = value ? Color.primary_white : Color.grey_four
                self.footerView.buttonNotPreference.setTitleColor(color, for: .normal)
                self.tableView.reloadData()
                self.lblPreferenceParty.text = "(Belum menentukan pilihan)"
                self.state = value
                self.viewModel.input.notPreferenceI.onNext((" "))
            })
            .disposed(by: disposeBag)
        
        viewModel.output.notPreferenceO
            .drive()
            .disposed(by: disposeBag)
    
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.input.viewWillAppearI.onNext(())
    }
}

