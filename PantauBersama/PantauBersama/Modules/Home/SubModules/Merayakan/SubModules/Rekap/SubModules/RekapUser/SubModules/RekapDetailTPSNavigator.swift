//
//  RekapDetailTPSNavigator.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 09/04/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import RxSwift
import Networking
import SimpleImageViewer

protocol RekapDetailTPSNavigator {
    func back() -> Observable<Void>
    func imageViewer(image: ImageResponse, data: UIImage?) -> Observable<Void>
}

final class RekapDetailTPSCoordinator: BaseCoordinator<Void> {
    
    private let navigationController: UINavigationController
    private let realCount: RealCount
    
    init(navigationController: UINavigationController, realCount: RealCount) {
        self.navigationController = navigationController
        self.realCount = realCount
    }
    
    override func start() -> Observable<Void> {
        let viewModel = RekapDetailTPSViewModel(navigator: self, realCount: self.realCount)
        let viewController = RekapDetailTPSController()
        viewController.viewModel = viewModel
        navigationController.pushViewController(viewController, animated: true)
        return Observable.empty()
    }
    
}

extension RekapDetailTPSCoordinator: RekapDetailTPSNavigator {
    func back() -> Observable<Void> {
        navigationController.popViewController(animated: true)
        return Observable.empty()
    }
    func imageViewer(image: ImageResponse, data: UIImage?) -> Observable<Void> {
        print("Image url: \(image.file.url)")
        let configuration = ImageViewerConfiguration { config in
            config.image = data
        }
        let imageViewerController = ImageViewerController(configuration: configuration)
        self.navigationController.present(imageViewerController, animated: true, completion: nil)
        return Observable.empty()
    }
}
