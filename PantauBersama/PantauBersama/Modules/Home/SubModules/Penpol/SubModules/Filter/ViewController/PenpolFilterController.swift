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
    var reloadTable: Bool = false
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
            .do(onNext: { [unowned self](filterItems) in
                self.reset()
                filterItems.forEach({ (filterItem) in
                    UserDefaults.setSelectedFilter(value: filterItem.id, isSelected: true)
                })
            })
            .bind(to: viewModel.input.filterTrigger)
            .disposed(by: disposeBag)
        
        btnApply.rx.tap
            .bind(to: viewModel.input.applyTrigger)
            .disposed(by: disposeBag)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.title = "Filter"
        
        if reloadTable {
            self.selectedFilter.removeAll()
            self.tableView.reloadData()
        }
        
        let back = UIBarButtonItem(image: #imageLiteral(resourceName: "back"), style: .plain, target: self, action: nil)
        back.rx.tap
            .bind { [unowned self](_) in
                self.navigationController?.popViewController(animated: true)
            }
            .disposed(by: disposeBag)
        
        let reset = UIBarButtonItem(title: "RESET", style: .plain, target: self, action: nil)
        reset.tintColor = Color.primary_red
        
        reset.rx.tap
            .bind { [unowned self](_) in
                self.reset()
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
    
    private func reset() {
        self.selectedFilter.forEach({ (filterItem) in
            UserDefaults.setSelectedFilter(value: filterItem.id, isSelected: false)
        })
        self.selectedFilter.removeAll()
        self.nameCluster = "Pilih Cluster"
        if let selectedRow = self.tableView.indexPathsForSelectedRows {
            selectedRow.forEach({ (indexPath) in
                DispatchQueue.main.async {
                    self.tableView.deselectRow(at: indexPath, animated: true)
                }
            })
        }
        UserDefaults.Account.reset(forKey: .clusterName)
    }
}

extension PenpolFilterController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.output.filterItems[section].items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = viewModel.output.filterItems[indexPath.section].items[indexPath.row]
        
        if item.isSelected {
            tableView.selectRow(at: indexPath, animated: false, scrollPosition: UITableView.ScrollPosition.none)
            selectedFilter.append(item)
        }
        
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
            print(UserDefaults.Account.get(forKey: .clusterName) ?? "")
            cell.textLabel?.text = UserDefaults.Account.get(forKey: .clusterName) ?? "Pilih Cluster"
            cell.textLabel?.font = UIFont(name: "Lato-Regular", size: 12)
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 20))
        view.backgroundColor = .white
        
        let separator = UIView()
        separator.translatesAutoresizingMaskIntoConstraints = false
        separator.backgroundColor = UIColor.groupTableViewBackground
        
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
        let selectedItem = viewModel.output.filterItems[indexPath.section].items[indexPath.row]
      
        if selectedItem.type == FilterViewType.text {
            if let navigationController = self.navigationController {
                if selectedItem.id == "janji-cluster" {
                    let viewModel = ClusterSearchViewModel()
                    viewModel.delegate = self
                    let vc = ClusterSearchController(viewModel: viewModel)
                    navigationController.pushViewController(vc, animated: true)
                }
                
                if selectedItem.id == "cluster-categories" {
                    let viewModel = KategoriClusterViewModel()
                    let vc = ClusterCategoryFilterController()
                    vc.viewModel = viewModel
                    viewModel.delegate = self
                    
                    navigationController.pushViewController(vc, animated: true)
                }
            }
        }
        
        if let selectedRows = tableView.indexPathsForSelectedRows {
            //1. remove all selected row
            selectedRows.forEach { (selectedIndex) in
                if selectedIndex.section == indexPath.section {
                    tableView.deselectRow(at: selectedIndex, animated: true)
                    
                    if let removeIndex = self.selectedFilter.lastIndex(where: { (filterItem) -> Bool in
                        return filterItem.paramKey == selectedItem.paramKey
                    }) {
                        let removeItem = self.selectedFilter[removeIndex]
                        UserDefaults.setSelectedFilter(value: removeItem.id, isSelected: false)
                        self.selectedFilter.remove(at: removeIndex)
                    }
                }
            }
        }
        
        //2. append selected item to the list of selectedFilter (validated to prevent duplication needed)
        if !self.selectedFilter.contains(where: { (filterItem) -> Bool in
            return filterItem.id == selectedItem.id
        }) {
            self.selectedFilter.append(selectedItem)
        }
        
        return indexPath
    }
    
    func tableView(_ tableView: UITableView, willDeselectRowAt indexPath: IndexPath) -> IndexPath? {
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
        UserDefaults.Account.set(item.name ?? "", forKey: .clusterName)
        DispatchQueue.main.async {
            self.viewModel.input.cidTrigger.onNext((values ?? ""))
            self.clusterId = values
            self.tableView.reloadData()
        }
        return Observable.just(())
    }
}

extension PenpolFilterController: ClusterCategoryDelegate {
    func didSelectCategory(item: ICategories) -> Observable<Void> {
        let values = item.id
        UserDefaults.Account.set(item.name ?? "", forKey: .clusterCategory)
        DispatchQueue.main.async {
            self.viewModel.input.cidTrigger.onNext((values ?? ""))
            self.clusterId = values
            self.tableView.reloadData()
        }
        return Observable.just(())
    }
}
