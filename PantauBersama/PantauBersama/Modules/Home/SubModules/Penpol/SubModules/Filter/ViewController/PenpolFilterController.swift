//
//  PenpolFilterControllerViewController.swift
//  PantauBersama
//
//  Created by Rahardyan Bisma on 07/01/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import UIKit
import Common
import RxSwift
import RxCocoa
import Networking

class PenpolFilterController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var btnApply: Button!
    var viewModel: PenpolFilterViewModel!
    private let disposeBag = DisposeBag()
    private var selectedFilter: [PenpolFilterModel.FilterItem] = []
    private var clusterId: String? = nil
    private var nameCluster: String? = "Pilih Cluster"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.registerReusableCell(FilterRadioCell.self)
        tableView.backgroundColor = .white
        tableView.separatorStyle = .none
        
        btnApply.rx.tap
            .map({ self.selectedFilter })
            .bind(to: viewModel.input.filterTrigger)
            .disposed(by: disposeBag)
        
        btnApply.rx.tap
            .bind(to: viewModel.input.applyTrigger)
            .disposed(by: disposeBag)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.title = "Filter"
        
        let back = UIBarButtonItem(image: #imageLiteral(resourceName: "back"), style: .plain, target: self, action: nil)
        back.rx.tap
            .bind { [unowned self](_) in
                self.navigationController?.popViewController(animated: true)
            }
            .disposed(by: disposeBag)
        
        let reset = UIBarButtonItem(title: "RESET", style: .plain, target: self, action: nil)
        reset.tintColor = #colorLiteral(red: 0.7418265939, green: 0.03327297792, blue: 0.1091294661, alpha: 1)
        
        reset.rx.tap
            .bind { [unowned self](_) in
                self.selectedFilter.removeAll()
                self.nameCluster = "Pilih Cluster"
                if let selectedRow = self.tableView.indexPathsForSelectedRows {
                    selectedRow.forEach({ (indexPath) in
                        DispatchQueue.main.async {
                            self.tableView.deselectRow(at: indexPath, animated: true)
                            self.tableView.reloadData()
                        }
                    })
                }
            }
            .disposed(by: disposeBag)
        
        viewModel.output.cid
            .drive(onNext: { [weak self] (s) in
                guard let `self` = self else { return }
                if let index = self.selectedFilter.index(where: { $0.paramKey == "cluster_id" }) {
                    self.selectedFilter[index].paramValue = s
                }
            }).disposed(by: disposeBag)
        
        self.navigationItem.leftBarButtonItem = back
        self.navigationItem.rightBarButtonItem = reset
        self.navigationController?.navigationBar.configure(with: .white)
    }
}

extension PenpolFilterController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.output.filterItems[section].items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var item = viewModel.output.filterItems[indexPath.section].items[indexPath.row]
        
        switch item.type {
        case .radio:
            let cell = tableView.dequeueReusableCell(withIdentifier: FilterRadioCell.reuseIdentifier) as! FilterRadioCell
            cell.tag = indexPath.row
            cell.configureCell(item: item)
            return cell
        case .text:
            // TODO: when user start to text item
            // will launch cluster search controller
            let cell = UITableViewCell()
            cell.textLabel?.text = self.nameCluster
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 20))
        view.backgroundColor = .white
        
        let separator = UIView()
        separator.translatesAutoresizingMaskIntoConstraints = false
        separator.backgroundColor = .lightGray
        
        let title = Label()
        title.typeLabel = "bold"
        title.fontSize = 14
        title.translatesAutoresizingMaskIntoConstraints = false
        title.text = viewModel.output.filterItems[section].title
        
        view.addSubview(separator)
        view.addSubview(title)
        
        NSLayoutConstraint.activate([
            separator.topAnchor.constraint(equalTo: view.topAnchor),
            separator.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            separator.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            separator.heightAnchor.constraint(equalToConstant: 1),
            
            title.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            title.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            title.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            title.heightAnchor.constraint(equalToConstant: 15)
            ])
        
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.output.filterItems.count
    }
    
}

extension PenpolFilterController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        var selectedItem = viewModel.output.filterItems[indexPath.section].items[indexPath.row]
      
        if selectedItem.type == FilterViewType.text {
            if let navigationController = self.navigationController {
                let viewModel = ClusterSearchViewModel()
                viewModel.delegate = self
                let vc = ClusterSearchController(viewModel: viewModel)
                navigationController.pushViewController(vc, animated: true)
            }
        }
        
        if let selectedRows = tableView.indexPathsForSelectedRows {
            selectedRows.forEach { (selectedIndex) in
                if selectedIndex.section == indexPath.section {
                    tableView.deselectRow(at: selectedIndex, animated: true)
                    
                    if let removeIndex = self.selectedFilter.lastIndex(where: { (filterItem) -> Bool in
                        return filterItem.paramKey == selectedItem.paramKey
                    }) {
                        self.selectedFilter.remove(at: removeIndex)
                    }
                }
            }
        }
        
        if !self.selectedFilter.contains(where: { (filterItem) -> Bool in
            return filterItem.paramValue == selectedItem.paramValue
        }) {
            
            self.selectedFilter.append(selectedItem)
        }
        
        return indexPath
    }
    
    func tableView(_ tableView: UITableView, willDeselectRowAt indexPath: IndexPath) -> IndexPath? {
        let item = viewModel.output.filterItems[indexPath.section].items[indexPath.row]
        if let selectedRows = tableView.indexPathsForSelectedRows {
            for row in selectedRows {
                if row == indexPath {
                    return nil
                }
            }
        }
        
        return indexPath
    }
}

extension PenpolFilterController: IClusterSearchDelegate {
    func didSelectCluster(item: ClusterDetail, index: IndexPath) -> Observable<Void> {
        let values = item.id
        let key = item.name
        DispatchQueue.main.async {
            self.viewModel.input.cidTrigger.onNext((values))
            self.nameCluster = key
            self.tableView.reloadData()
        }
        return Observable.just(())
    }
}
