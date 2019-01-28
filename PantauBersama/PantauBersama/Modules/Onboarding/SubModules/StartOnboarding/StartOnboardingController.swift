//
//  StartOnboardingController.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 20/01/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import RxSwift
import RxCocoa
import UIKit

enum PageViews: Int {
    case firstItem
    case secondItem
    case thirdItem
    case fourthItem
    case fiveItem
}

final class StartOnboardingController: UIViewController {
    
    @IBOutlet weak var container: UIView!
    @IBOutlet weak var btnSkip: UIButton!
    @IBOutlet weak var btnNext: UIButton!
    @IBOutlet weak var pageControl: UIPageControl!
    
    let pageContrainer: UIPageViewController = {
        let page = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        page.view.translatesAutoresizingMaskIntoConstraints = false
        return page
    }()
    
    fileprivate lazy var orderedViewController: [UIViewController] = {
        return [
            self.getOnboardingItemVC(item: .firstItem),
            self.getOnboardingItemVC(item: .secondItem),
            self.getOnboardingItemVC(item: .thirdItem),
            self.getOnboardingItemVC(item: .fourthItem),
            self.getOnboardingItemVC(item: .fiveItem)
        ]
    }()
    
    var currentIndex: Int = 0
    var pendingIndex: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupPageViewController()
    }
    
    
    private func setupPageViewController() {
        addChild(pageContrainer)
        container.addSubview(pageContrainer.view)
        
        NSLayoutConstraint.activate([
            pageContrainer.view.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            pageContrainer.view.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            pageContrainer.view.widthAnchor.constraint(equalTo: container.widthAnchor),
            pageContrainer.view.heightAnchor.constraint(equalTo: container.heightAnchor)
        ])
        
        pageContrainer.dataSource = self
        pageContrainer.delegate = self
        
        if let firstVC = orderedViewController.first {
            pageContrainer.setViewControllers([firstVC], direction: .forward, animated: true, completion: nil)
        }
        pageControl.numberOfPages = orderedViewController.count
        pageControl.currentPage = 0
    }
    
    func getOnboardingItemVC(item: PageViews) -> ItemOnboardingController {
        let ob = ItemOnboardingController()
        switch item {
        case .firstItem:
            ob.item = OnboardingiItem(title: "Voice Over Noise", description: "Linimasa konten kampanye resmi tanpa sampah informasi.", lottieAnimationView: "ob2_linimasa")
            return ob
        case .secondItem:
            ob.item = OnboardingiItem(title: "Understanding Over Branding", description: "Fleksibilitas uji preferensi kebijakan kandidat calon pemimpin.", lottieAnimationView: "ob3_penpol")
            return ob
        case .thirdItem:
            ob.item = OnboardingiItem(title: "Chivalry Over Bigotry", description: "Ruang adu argumentasi sehat dan berkualitas.", lottieAnimationView: "ob1_wordstadium")
            return ob
        case .fourthItem:
            ob.item = OnboardingiItem(title: "Inspector Over Spectator", description: "Kemudahan pelaporan dugaan pelanggaran Pemilu 2019.", lottieAnimationView: "ob4_lapor")
            return ob
        case .fiveItem:
            ob.item = OnboardingiItem(title: "Festivity Over Apathy", description: "Rekapitulasi partisipatif real-time dan transparan.", lottieAnimationView: "ob5_perhitungan")
            return ob
        }
    }
    
    @IBAction func handleSkip(_ sender: UIButton) {
        self.handleAppCoordinator()
    }
    
    @IBAction func handleNext(_ sender: UIButton) {
        if orderedViewController.count > pageControl.currentPage {
            self.pageContrainer.goToNextPage()
            pageControl.currentPage += 1
            if pageControl.currentPage == 4 {
                self.btnNext.setTitle("SELESAI", for: .normal)
                // TODO: Go to app Coordinator
                self.handleAppCoordinator()
            }
        }
    }
    
    private func handleAppCoordinator() {
        let defaults = UserDefaults.standard
        defaults.set("No", forKey:"isFirstTime")
        defaults.synchronize()
        
        if let app = UIApplication.shared.delegate as? AppDelegate, let window = app.window {
            let disposeBag = DisposeBag()
            let appCordinator = AppCoordinator(window: window)
            appCordinator.start()
                .subscribe()
                .disposed(by: disposeBag)
        }
    }
    
}

extension StartOnboardingController: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewController.index(of: viewController) else { return nil }
        let previousIndex = viewControllerIndex - 1
        guard previousIndex >= 0 else { return nil }
        guard orderedViewController.count > previousIndex else { return nil }
        return orderedViewController[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewController.index(of: viewController) else { return nil }
        let nextIndex = viewControllerIndex + 1
        guard nextIndex < orderedViewController.count else { return nil }
        guard orderedViewController.count > nextIndex else { return nil }
        return orderedViewController[nextIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        pendingIndex = orderedViewController.index(of: pendingViewControllers.first! as! ItemOnboardingController)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if completed {
            if let pIndex = pendingIndex {
                currentIndex = pIndex
            }
            pageControl.currentPage = currentIndex
            self.btnNext.setTitle("LANJUT", for: .normal)
            if currentIndex == 4 {
                self.btnNext.setTitle("SELESAI", for: .normal)
            }
        }
    }
}

extension UIPageViewController {
    func goToNextPage(animated: Bool = true, completion: ((Bool) -> Void)? = nil) {
        if let currentViewController = viewControllers?[0] {
            if let nextPage = dataSource?.pageViewController(self, viewControllerAfter: currentViewController) {
                setViewControllers([nextPage], direction: .forward, animated: animated, completion: completion)
            }
        }
    }
}
