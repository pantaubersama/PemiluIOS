//
//  UploadC1Controller.swift
//  PantauBersama
//
//  Created by Nanang Rafsanjani on 04/03/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import UIKit
import Common
import RxSwift
import RxCocoa
import RxDataSources

class UploadC1Controller: UIViewController {
    var viewModel: UploadC1ViewModel!
    
    private let disposeBag = DisposeBag()
    
    @IBOutlet weak var tableView: UITableView!
    
    lazy var header = UIView.nib(withType: UploadC1Header.self)
    private var dataSource: RxTableViewSectionedAnimatedDataSource<SectionC1Models>!
    
//    var titles = [
//        "1. Model C1-PPWP (Presiden)",
//        "2. Model C1-DPR RI",
//        "3. Model C1-DPD",
//        "4. Model C1-DPRD Provinsi",
//        "5. Model C1-DPRD Kabupaten/Kota",
//        "6. Suasana TPS"
//    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Upload"
        
        let back = UIBarButtonItem(image: #imageLiteral(resourceName: "back"), style: .plain, target: nil, action: nil)
        
        navigationItem.leftBarButtonItem = back
        navigationController?.navigationBar.configure(with: .white)
        
        back.rx.tap
            .bind(to: viewModel.input.backI)
            .disposed(by: disposeBag)
        
        tableView.delegate = nil
        tableView.dataSource = nil
        tableView.setTableHeaderView(headerView: header)
        tableView.registerReusableCell(C1PhotoCell.self)
        tableView.registerReusableHeaderCell(C1PhotoHeader.self)
        tableView.rx.setDelegate(self)
            .disposed(by: disposeBag)
        
        dataSource = UploadC1Controller.dataSource()
        
        let sections: [SectionC1Models] = [SectionC1Models(header: "1. Model C1-PPWP (Presiden)", items: []),
                                           SectionC1Models(header: "2. Model C1-DPR RI", items: []),
                                           SectionC1Models(header: "3. Model C1-DPD", items: []),
                                           SectionC1Models(header: "4. Model C1-DPRD Provinsi", items: []),
                                           SectionC1Models(header: "5. Model C1-DPRD Kabupaten/Kota", items: []),
                                           SectionC1Models(header: "6. Suasana TPS", items: [])]
        
        let initialState = SectionC1TableViewState(section: sections)
        
        let addCommand = self.viewModel.relayImages.asObservable()
            .map({ TableViewEditingCommand.AppendItem(item: $0, section: $0.section )})
        
        let deleteCommand = tableView.rx.itemDeleted.asObservable()
            .map(TableViewEditingCommand.DeleteItem)
        
        Observable.of(addCommand, deleteCommand)
            .merge()
            .scan(initialState) { (state: SectionC1TableViewState, command: TableViewEditingCommand) -> SectionC1TableViewState in
                return state.executeCommand(command: command)
            }
            .startWith(initialState)
            .map {
                $0.section
            }
            .share(replay: 1)
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        
        viewModel.output.backO
            .drive()
            .disposed(by: disposeBag)
        
        viewModel.output.addImageO
            .do(onNext: { [weak self] (section) in
                guard let `self` = self else { return }
                let controller = UIImagePickerController()
                controller.sourceType = .photoLibrary
                controller.delegate = self
                self.navigationController?.present(controller, animated: true, completion: nil)
            })
            .drive()
            .disposed(by: disposeBag)
        
        viewModel.output.imageUpdatedO
            .drive()
            .disposed(by: disposeBag)
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.updateHeaderViewFrame()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tableView.setEditing(true, animated: true)
    }
}

extension UploadC1Controller: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooter() as C1PhotoHeader
        header.lblTitle.text = dataSource.sectionModels[section].header
        
        
        header.btnAdd.rx.tap
            .subscribe(onNext: { [weak self] (_) in
                guard let `self` = self else { return }
                self.viewModel.input.addImagesI.onNext(section)
            })
            .disposed(by: self.disposeBag)

        return header
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = Color.grey_one
        return view
    }
}


extension UploadC1Controller: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        navigationController?.dismiss(animated: true, completion: { [weak self] in
            guard let `self` = self else { return }
            if let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
                print("Edited image")
                self.viewModel.input.imagesI.onNext(image)
            } else if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
                print("ORIGINAL")
                self.viewModel.input.imagesI.onNext(image)
            }
        })
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.navigationController?.dismiss(animated: true, completion: nil)
        self.viewModel.input.imagesI.onNext(nil)
    }
    
}


extension UploadC1Controller {
    
    static func dataSource() -> RxTableViewSectionedAnimatedDataSource<SectionC1Models> {
        return RxTableViewSectionedAnimatedDataSource(
            animationConfiguration: AnimationConfiguration(insertAnimation: .top, reloadAnimation: .fade, deleteAnimation: .left),
            configureCell: { (dataSource, table, idxPath, item) in
                let cell = table.dequeueReusableCell(indexPath: idxPath) as C1PhotoCell
                return cell
            },
            canEditRowAtIndexPath: { _, _ in
                return true
            },
            canMoveRowAtIndexPath: { _, _ in
                return true
            }
        )
    }
    
}
