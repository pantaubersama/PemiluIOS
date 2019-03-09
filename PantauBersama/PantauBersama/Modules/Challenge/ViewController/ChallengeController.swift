//
//  ChallengeController.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 15/02/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Common
import Networking
import URLEmbeddedView

class ChallengeController: UIViewController {
    
    @IBOutlet weak var footerProfileView: FooterProfileView!
    @IBOutlet weak var containerHeader: UIView!
    @IBOutlet weak var lblHeader: UILabel!
    @IBOutlet weak var headerTantanganView: HeaderTantanganView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var challengeButton: ChallengeButtonView!
    @IBOutlet weak var containerContent: UIView!
    @IBOutlet weak var imageContent: UIImageView!
    @IBOutlet weak var titleContent: UILabel!
    @IBOutlet weak var subtitleContent: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var containerAcceptChallenge: UIView!
    @IBOutlet weak var containerTerima: RoundView!
    @IBOutlet weak var btnTerima: Button!
    @IBOutlet weak var btnImageTerima: UIImageView!
    @IBOutlet weak var containerTolak: RoundView!
    @IBOutlet weak var btnTolak: Button!
    @IBOutlet weak var containerDebatDone: UIView!
    @IBOutlet weak var detailTantanganView: ChallengeDetailView!
    @IBOutlet weak var refuseChallengeView: RefuseChallengeView!
    @IBOutlet weak var constraintDetailChallenge: NSLayoutConstraint!
    @IBOutlet weak var ivChallengerDone: CircularUIImageView!
    @IBOutlet weak var lblClapsChallengerDone: Label!
    @IBOutlet weak var ivOpponentsDone: CircularUIImageView!
    @IBOutlet weak var lblClapsOpponentsDone: Label!
    
    @IBOutlet weak var btnBack: ImageButton!
    
    var viewModel: ChallengeViewModel!
    var data: Challenge!
    private let disposeBag: DisposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        btnBack.rx.tap
            .bind(to: viewModel.input.backI)
            .disposed(by: disposeBag)
        
        btnTerima.rx.tap
            .bind(to: viewModel.input.actionButtonI)
            .disposed(by: disposeBag)
        
        btnTolak.rx.tap
            .bind(to: viewModel.input.refuseII)
            .disposed(by: disposeBag)
        
        challengeButton.btnShare.rx.tap
            .bind(to: viewModel.input.shareI)
            .disposed(by: disposeBag)
        
        challengeButton.btnMore.rx.tap
            .map({ self.data })
            .bind(to: viewModel.input.moreI)
            .disposed(by: disposeBag)
        
        viewModel.output.backO
            .drive()
            .disposed(by: disposeBag)
        
        viewModel.output.actionO
            .drive()
            .disposed(by: disposeBag)
        
        viewModel.output.challengeO
            .drive(onNext: { [weak self] (challenge) in
                guard let `self` = self else { return }
                self.configureContent(data: challenge)
            })
            .disposed(by: disposeBag)
        
        viewModel.output.refuseO
            .drive()
            .disposed(by: disposeBag)
        
        viewModel.output.shareO
            .drive()
            .disposed(by: disposeBag)
        
        viewModel.output.moreO
            .asObservable()
            .flatMapLatest { [weak self] (challenge) -> Observable<ChallengeDetailType> in
                return Observable.create({ (observer) -> Disposable in
                    let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
                    let me = AppState.local()?.user
                    let hapus = UIAlertAction(title: "Hapus Challenge", style: .default, handler: { (_) in
                        observer.onNext(ChallengeDetailType.hapus(id: challenge.id))
                        observer.on(.completed)
                    })
                    let salin = UIAlertAction(title: "Salin Tautan", style: .default, handler: { (_) in
                        observer.onNext(ChallengeDetailType.salin(data: challenge))
                        observer.on(.completed)
                    })
                    
                    let bagikan = UIAlertAction(title: "Bagikan", style: .default, handler: { (_) in
                        observer.onNext(ChallengeDetailType.share(data: challenge))
                        observer.on(.completed)
                    })
                    
                    let cancel = UIAlertAction(title: "Batal", style: .cancel, handler: nil)
                    // TODO
                    // this function is to check user id match with audience of the challenge
                    // and the challenge audience just one and user id is match
                    if challenge.audiences.first?.userId == me?.id && challenge.audiences.count == 1 {
                        alert.addAction(hapus)
                    }
                    alert.addAction(salin)
                    alert.addAction(bagikan)
                    alert.addAction(cancel)
                    DispatchQueue.main.async {
                        self?.navigationController?.present(alert, animated: true, completion: nil)
                    }
                    return Disposables.create()
                })
            }
            .bind(to: viewModel.input.moreMenuI)
            .disposed(by: disposeBag)
        
        viewModel.output.moreMenuO
            .filter { !$0.isEmpty }
            .drive(onNext: { (message) in
                UIAlertController.showAlert(withTitle: "", andMessage: message)
            })
            .disposed(by: disposeBag)
    
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.isHidden = false
    }
}

extension ChallengeController {
    
    // MARK
    // Refresh with data challenge type
    private func configureContent(data: Challenge) {
        let myEmail = AppState.local()?.user.email ?? ""
        let challenger = data.audiences.filter({ $0.role == .challenger }).first
        let opponents = data.audiences.filter({ $0.role != .challenger })
        // temporary use email, because user id and audience id are different from BE
        let isMyChallenge = myEmail == (challenger?.email ?? "")
        let isAudience = opponents.contains(where: { ($0.email ?? "") == myEmail })
        
        switch data.progress {
        case .waitingConfirmation:
            self.lblHeader.text = data.type.title
        case .waitingOpponent:
            self.lblHeader.text = data.type.title
        case .comingSoon:
            self.lblHeader.text = data.progress.title
        case .done:
            self.lblHeader.text = data.progress.title
        default:
            self.lblHeader.text = data.type.title
        }
        
        self.lblHeader.text = data.type.title
        
        // configure header challenger side
        self.headerTantanganView.avatar.show(fromURL: challenger?.avatar?.url ?? "")
        self.headerTantanganView.lblFullName.text = challenger?.fullName ?? ""
        self.headerTantanganView.lblUsername.text = challenger?.username ?? ""
        
        // if there is an opponents candidate, then configure header opponent side
        if let opponent = opponents.first {
            self.headerTantanganView.containerOpponent.isHidden = false
            self.headerTantanganView.avatarOpponent.show(fromURL: opponent.avatar?.url ?? "")
            
            if opponent.role == .opponent {
                self.headerTantanganView.lblNameOpponent.isHidden = false
                self.headerTantanganView.lblNameOpponent.text = opponent.fullName
                self.headerTantanganView.lblUsernameOpponent.isHidden = false
                self.headerTantanganView.lblUsernameOpponent.text = opponent.username
            } else {
                self.headerTantanganView.lblCountOpponent.isHidden = false
                self.headerTantanganView.lblCountOpponent.text = data.type == .directChallenge ? "" : "\(opponents.count)"
                self.headerTantanganView.lblNameOpponent.isHidden = data.type == .directChallenge ? false : true
                self.headerTantanganView.lblNameOpponent.text = opponent.fullName
                self.headerTantanganView.lblUsernameOpponent.isHidden = data.type == .directChallenge ? false : true
                self.headerTantanganView.lblUsernameOpponent.text = opponent.username
            }
        }
        
        /// configure challenge detail view and refresh layout
        self.detailTantanganView.configureData(data: data)
        self.configureLayoutDetailChallenge(data: data)
        
        // configure footer view
        self.footerProfileView.ivAvatar.show(fromURL: challenger?.avatar?.url ?? "")
        self.footerProfileView.lblName.text = challenger?.fullName ?? ""
        self.footerProfileView.lblStatus.text = challenger?.about ?? ""
        self.footerProfileView.lblPostTime.text = "Posted \(data.createdAt?.timeAgoSinceDateForm2 ?? "")"
        
        /**
         Configure Challenge Detail with data Model.
         - Parameters:
         - Challenge type = Direct and Open.
         - Progress type have condition waiting opponent, waiting confirmation, coming soon, live now and done.
         - Condition type like ongoing, expired, and rejected.
         
         Please make sure from three user prespective, fighter, opponents, and others.
         **/
        
        switch data.progress {
        case .waitingConfirmation:
            switch data.type {
            case .directChallenge:
                switch data.condition {
                    case .rejected:
                        self.titleContent.text = "Tantangan ditolak,"
                        self.subtitleContent.text = "lawan debat tidak menerima tantangan ini:("
                        self.subtitleContent.textColor = #colorLiteral(red: 0.7424071431, green: 0.03536110744, blue: 0.1090037152, alpha: 1)
                        self.refuseChallengeView.isHidden = false
                        self.containerAcceptChallenge.isHidden = true
                        self.refuseChallengeView.configureData(data: opponents)
                        self.containerHeader.backgroundColor = #colorLiteral(red: 1, green: 0.4935973287, blue: 0.3663615584, alpha: 1)
                        self.headerTantanganView.lblStatus.isHidden = false
                        self.headerTantanganView.lblStatus.text = "DENIED"
                    case .ongoing:
                        if isAudience { // if user already registered as opponent candidate
                            self.titleContent.text = "Ini tantangan buat kamu,"
                            self.subtitleContent.text = "apakah dikonfirmasi?"
                            self.containerHeader.backgroundColor = #colorLiteral(red: 1, green: 0.4935973287, blue: 0.3663615584, alpha: 1)
                            self.containerAcceptChallenge.isHidden = false
                            self.containerTolak.isHidden = false
                            self.imageContent.image = #imageLiteral(resourceName: "waitingMask")
                        } else {
                            self.titleContent.text = "Menunggu,"
                            self.subtitleContent.text = "\(opponents.first?.fullName ?? "")\nmengkonfirmasi tantangan"
                            self.containerHeader.backgroundColor = #colorLiteral(red: 1, green: 0.4935973287, blue: 0.3663615584, alpha: 1)
                            self.containerAcceptChallenge.isHidden = true
                            self.imageContent.image = #imageLiteral(resourceName: "waitingMask")
                    }
                    case .expired:
                        self.titleContent.text = "Tantangan tidak valid."
                        self.subtitleContent.textColor = #colorLiteral(red: 0.7424071431, green: 0.03536110744, blue: 0.1090037152, alpha: 1)
                        self.subtitleContent.text = "Tantangan melebihi batas waktu :("
                        self.containerAcceptChallenge.isHidden = true
                        self.containerHeader.backgroundColor = #colorLiteral(red: 1, green: 0.4935973287, blue: 0.3663615584, alpha: 1)
                        self.headerTantanganView.lblStatus.isHidden = false
                        self.headerTantanganView.lblStatus.text = "EXPIRED"
                default: break
                }
            case .openChallenge:
                switch data.condition {
                case .expired:
                    self.titleContent.text = "Tantangan tidak valid."
                    self.subtitleContent.text = "Tantangan melebihi batas waktu :("
                    self.subtitleContent.textColor = #colorLiteral(red: 0.7424071431, green: 0.03536110744, blue: 0.1090037152, alpha: 1)
                    self.headerTantanganView.lblStatus.isHidden = false
                    self.headerTantanganView.lblStatus.text = "EXPIRED"
                    
                    self.tableView.isHidden = false
                    self.configureTableOpponentCandidate(isMyChallenge: isMyChallenge, isExpired: true)
                case .ongoing:
                    if isAudience { // if user already registered as opponent candidate
                        self.titleContent.text = "Menunggu,"
                        self.subtitleContent.text = "\(challenger?.fullName ?? "") untuk\nkonfirmasi lawan debat"
                        self.containerHeader.backgroundColor = #colorLiteral(red: 1, green: 0.4935973287, blue: 0.3663615584, alpha: 1)
                        self.containerAcceptChallenge.isHidden = true
                    } else if isMyChallenge { // if user is the owner of challenge
                        self.titleContent.text = "Tantangan diterima,"
                        self.subtitleContent.text = "Segera konfirmasi sebelum\nbatas akhir waktunya!"
                        self.containerHeader.backgroundColor = #colorLiteral(red: 1, green: 0.4935973287, blue: 0.3663615584, alpha: 1)
                        self.containerAcceptChallenge.isHidden = true
                        self.imageContent.image = #imageLiteral(resourceName: "waitingMask")
                    } else { // if user not the owner and has not registered yet
                        self.titleContent.text = "Ini adalah Open Challenge,"
                        self.subtitleContent.text = "Terima tantangan ini?"
                        self.containerHeader.backgroundColor = #colorLiteral(red: 1, green: 0.4935973287, blue: 0.3663615584, alpha: 1)
                        self.containerAcceptChallenge.isHidden = false
                    }
                    
                    self.tableView.isHidden = false
                    self.configureTableOpponentCandidate(isMyChallenge: isMyChallenge, isExpired: false)
                default: break
                }
             
            default: break
            }
        case .waitingOpponent:
            switch data.type {
            case .directChallenge:
                if isAudience { // if user already registered as opponent candidate
                    self.titleContent.text = "Ini tantangan buat kamu,"
                    self.subtitleContent.text = "apakah dikonfirmasi?"
                    self.containerHeader.backgroundColor = #colorLiteral(red: 1, green: 0.4935973287, blue: 0.3663615584, alpha: 1)
                    self.containerAcceptChallenge.isHidden = false
                    self.containerTolak.isHidden = false
                    self.imageContent.image = #imageLiteral(resourceName: "waitingMask")
                } else {
                    self.titleContent.text = "Menunggu,"
                    self.subtitleContent.text = "\(opponents.first?.fullName ?? "")\nmengkonfirmasi tantangan"
                    self.containerHeader.backgroundColor = #colorLiteral(red: 1, green: 0.4935973287, blue: 0.3663615584, alpha: 1)
                    self.containerAcceptChallenge.isHidden = true
                    self.imageContent.image = #imageLiteral(resourceName: "waitingMask")
                }
            case .openChallenge:
                if isMyChallenge {
                    self.titleContent.text = "Menunggu,"
                    self.subtitleContent.text = "lawan menerima\ntantanganmu"
                    self.containerHeader.backgroundColor = #colorLiteral(red: 1, green: 0.4935973287, blue: 0.3663615584, alpha: 1)
                    self.containerAcceptChallenge.isHidden = true
                } else {
                    self.titleContent.text = "Ini adalah Open Challenge,"
                    self.subtitleContent.text = "Terima tantangan ini?"
                    self.containerHeader.backgroundColor = #colorLiteral(red: 1, green: 0.4935973287, blue: 0.3663615584, alpha: 1)
                    self.containerAcceptChallenge.isHidden = false
                }
            default: break
            }
        case .comingSoon:
            self.lblHeader.text = "COMING SOON"
            self.titleContent.text = "Siap-siap!"
            self.subtitleContent.text = "Debat akan berlangsung pada \(data.showTimeAt?.timeLaterSinceDate ?? "")"
            self.headerTantanganView.backgroundChallenge.image = #imageLiteral(resourceName: "comingSoonBG")
            self.containerHeader.backgroundColor = #colorLiteral(red: 0.1167989597, green: 0.5957490802, blue: 0.8946897388, alpha: 1)
            self.tableView.isHidden = true
            self.containerAcceptChallenge.isHidden = true
            self.imageContent.image = #imageLiteral(resourceName: "comingSoonMask")
        case .done:
            self.titleContent.text = "Debat selesai,"
            self.subtitleContent.text = "Inilah hasilnya:"
            self.headerTantanganView.configureType(type: .done)
            self.containerHeader.backgroundColor = #colorLiteral(red: 0.3294117647, green: 0.2549019608, blue: 0.6, alpha: 1)
            self.lblHeader.text = "DONE"
            self.imageContent.image = #imageLiteral(resourceName: "doneMask")
            self.containerDebatDone.isHidden = false
            self.ivChallengerDone.show(fromURL: challenger?.avatar?.url ?? "")
            self.ivOpponentsDone.show(fromURL: opponents.first?.avatar?.url ?? "")
            self.btnTerima.backgroundColor = #colorLiteral(red: 1, green: 0.5569574237, blue: 0, alpha: 1)
            self.btnImageTerima.image = #imageLiteral(resourceName: "outlineDebateDone24PxWhite")
            self.btnTerima.setTitle("LIHAT DEBAT", for: UIControlState())
            self.containerAcceptChallenge.isHidden = false
            self.challengeButton.configure(type: .done, viewModel: self.viewModel, data: data)
        default:
            break
        }
    }
    
    private func configureTableOpponentCandidate(isMyChallenge: Bool, isExpired: Bool) {
        tableView.registerReusableCell(UserChallengeCell.self)
        tableView.rowHeight = 53
        
        tableView.delegate = nil
        tableView.dataSource = nil
        viewModel.output.audienceO
            .drive(tableView.rx.items) { [unowned self]tableView, row, item -> UITableViewCell in
                let cell = tableView.dequeueReusableCell() as UserChallengeCell
                cell.configureCell(item: UserChallengeCell.Input(audience: item, viewModel: self.viewModel, isMyChallenge: isMyChallenge, isExpired: isExpired))
                return cell
            }
            .disposed(by: disposeBag)
        
    }
}


extension ChallengeController {
    
    /**
     Configure constraint layout if type both Open Challenge and Direct
     constraint height for default size is 362
     - Parameters:
        need a Challenge Model
     **/
    
    private func configureLayoutDetailChallenge(data: Challenge) {
        switch data.type {
        case .directChallenge:
            self.detailTantanganView.spacingLawanDebat.isHidden = false
            if data.source != "" {
                self.constraintDetailChallenge.constant = 362 + 70 + 60
            } else {
                self.constraintDetailChallenge.constant = 362 + 60
            }
        case .openChallenge:
            if data.source != "" {
                self.constraintDetailChallenge.constant = 362 + 70
            } else {
                self.constraintDetailChallenge.constant = 362
            }
        default:
            break
        }
    }
    
}
