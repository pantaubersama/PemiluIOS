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
    @IBOutlet weak var btnSave: Button!
    
    lazy var header = UIView.nib(withType: UploadC1Header.self)
    private var dataSource: RxTableViewSectionedAnimatedDataSource<SectionC1Models>!
    private var bufferSection: Int = 0
    private var sectionModel: [SectionC1Models] = []
    private var isSaved: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Upload"
        
        let back = UIBarButtonItem(image: #imageLiteral(resourceName: "back"), style: .plain, target: nil, action: nil)
        
        navigationItem.leftBarButtonItem = back
        navigationController?.navigationBar.configure(with: .white)
        
        back.rx.tap
            .bind(to: viewModel.input.backI)
            .disposed(by: disposeBag)
        
        btnSave.rx.tap
            .bind(to: viewModel.input.simpanI)
            .disposed(by: disposeBag)
        
        tableView.delegate = nil
        tableView.dataSource = nil
        tableView.setTableHeaderView(headerView: header)
        tableView.registerReusableCell(C1PhotoCell.self)
        tableView.registerReusableHeaderCell(C1PhotoHeader.self)
        tableView.rx.setDelegate(self)
            .disposed(by: disposeBag)
        
    
        dataSource = UploadC1Controller.dataSource()
        
    
        let sections: [SectionC1Models] = [SectionC1Models(header: "1. Model C1-PPWP (Presiden)", items: self.viewModel.presidenImageRelay.value),
                                           SectionC1Models(header: "2. Model C1-DPR RI", items: self.viewModel.dprImageRelay.value),
                                           SectionC1Models(header: "3. Model C1-DPD", items: self.viewModel.dpdImageRelay.value),
                                           SectionC1Models(header: "4. Model C1-DPRD Provinsi", items: self.viewModel.dprdProvImageRelay.value),
                                           SectionC1Models(header: "5. Model C1-DPRD Kabupaten/Kota", items: self.viewModel.dprdImageRelay.value),
                                           SectionC1Models(header: "6. Suasana TPS", items: self.viewModel.suasanaImageRelay.value)]
        
        let initialState = SectionC1TableViewState(section: sections)
        
        let addCommand = self.viewModel.output.imageUpdatedO
            .asObservable()
            .distinctUntilChanged()
            .map({ TableViewEditingCommand.AppendItem(item: $0, section: $0.section )})
        
        let deleteCommand = tableView.rx.itemDeleted.asObservable()
            .do(onNext: { (indexPath) in
                print("deleting images in : \(indexPath)")
                switch indexPath.section {
                case 0:
                    var latestValue = self.viewModel.presidenImageRelay.value
                    let models = latestValue[indexPath.row]
                    if models.url == nil {
                        // assume this value is from local
                    } else {
                        self.viewModel.input.deleteImagesI.onNext(models.id ?? "")
                    }
                    latestValue.remove(at: indexPath.row)
                    self.viewModel.presidenImageRelay.accept(latestValue)
                case 1:
                    var latestValue = self.viewModel.dprImageRelay.value
                    let models = latestValue[indexPath.row]
                    if models.url == nil {
                        // assume this value is from local
                    } else {
                        self.viewModel.input.deleteImagesI.onNext(models.id ?? "")
                    }
                    latestValue.remove(at: indexPath.row)
                    self.viewModel.dprImageRelay.accept(latestValue)
                case 2:
                    var latestValue = self.viewModel.dpdImageRelay.value
                    let models = latestValue[indexPath.row]
                    if models.url == nil {
                        // assume this value is from local
                    } else {
                        self.viewModel.input.deleteImagesI.onNext(models.id ?? "")
                    }
                    latestValue.remove(at: indexPath.row)
                    self.viewModel.dpdImageRelay.accept(latestValue)
                case 3:
                    var latestValue = self.viewModel.dprdProvImageRelay.value
                    let models = latestValue[indexPath.row]
                    if models.url == nil {
                        // assume this value is from local
                    } else {
                        self.viewModel.input.deleteImagesI.onNext(models.id ?? "")
                    }
                    latestValue.remove(at: indexPath.row)
                    self.viewModel.dprdProvImageRelay.accept(latestValue)
                case 4:
                    var latestValue = self.viewModel.dprdImageRelay.value
                    let models = latestValue[indexPath.row]
                    if models.url == nil {
                        // assume this value is from local
                    } else {
                        self.viewModel.input.deleteImagesI.onNext(models.id ?? "")
                    }
                    latestValue.remove(at: indexPath.row)
                    self.viewModel.dprdImageRelay.accept(latestValue)
                case 5:
                    var latestValue = self.viewModel.suasanaImageRelay.value
                    let models = latestValue[indexPath.row]
                    if models.url == nil {
                        // assume this value is from local
                    } else {
                        self.viewModel.input.deleteImagesI.onNext(models.id ?? "")
                    }
                    latestValue.remove(at: indexPath.row)
                    self.viewModel.suasanaImageRelay.accept(latestValue)
                default: break
                }
            })
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
                controller.allowsEditing = true
                self.navigationController?.present(controller, animated: true, completion: nil)
                self.bufferSection = section
            })
            .drive()
            .disposed(by: disposeBag)
        
        viewModel.output.simpanO
            .drive()
            .disposed(by: disposeBag)
        
        viewModel.output.deletedImagesO
            .drive()
            .disposed(by: disposeBag)
        
        viewModel.output.realCountO
            .drive(onNext: { [weak self] (data) in
                guard let `self` = self else { return }
                if data.status == .published {
                    self.btnSave.isEnabled = false
                    self.isSaved = true
                    let btnAttr = NSAttributedString(string: "Data Terkirim",
                                                     attributes: [NSAttributedString.Key.foregroundColor : Color.cyan_warm_light])
                    self.btnSave.setAttributedTitle(btnAttr, for: .normal)
                }
                
            })
            .disposed(by: self.disposeBag)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.updateHeaderViewFrame()
        
        viewModel.output.initialDataO
            .drive()
            .disposed(by: disposeBag)
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
        
        if self.isSaved == true {
            header.btnAdd.isEnabled = false
        } else {
            header.btnAdd.rx.tap
                .subscribe(onNext: { [weak self] (_) in
                    guard let `self` = self else { return }
                    self.viewModel.input.addImagesI.onNext(section)
                })
                .disposed(by: self.disposeBag)
        }
        

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
                self.viewModel.input.imagesI.onNext(StashImages(section: self.bufferSection, images: image, id: UUID().uuidString, url: nil))
            } else if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
                print("ORIGINAL")
                self.viewModel.input.imagesI.onNext(StashImages(section: self.bufferSection, images: image, id: UUID().uuidString, url: nil))
            }
        })
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.navigationController?.dismiss(animated: true, completion: nil)
        self.viewModel.input.imagesI.onNext(StashImages(section: 7, images: nil, id: UUID().uuidString, url: nil))
    }
    
}


extension UploadC1Controller {
    
    static func dataSource() -> RxTableViewSectionedAnimatedDataSource<SectionC1Models> {
        return RxTableViewSectionedAnimatedDataSource(
            animationConfiguration: AnimationConfiguration(insertAnimation: .top, reloadAnimation: .fade, deleteAnimation: .left),
            configureCell: { (dataSource, table, idxPath, item) in
                let cell = table.dequeueReusableCell(indexPath: idxPath) as C1PhotoCell
                cell.configureCell(item: C1PhotoCell.Input(data: item, title: "\(idxPath.row + 1)"))
                return cell
            },
            canEditRowAtIndexPath: { _, _ in
                return true
            })
    }
    
}
