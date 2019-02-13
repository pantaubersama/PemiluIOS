//
//  HintTantanganView.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 12/02/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Common

class HintTantanganView: UIViewController {
    
    @IBOutlet weak var lblContent: Label!
    @IBOutlet weak var lblTitle: UILabel!
    var viewModel: HintTantanganViewModel!
    @IBOutlet weak var btnClose: Button!
    
    private let disposeBag: DisposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        btnClose.rx.tap
            .bind(to: viewModel.input.closeI)
            .disposed(by: disposeBag)
        
        
        viewModel.output.hintO
            .do(onNext: { [unowned self] (type) in
                switch type {
                case .kajian:
                    self.lblTitle.text = "BIDANG KAJIAN"
                    self.lblContent.text = "Bidang Kajian menunjukkan topik yang sedang dibahas dalam perdebatan. Misalnya Ekonomi, Sosial, Budaya, Agama, Tata Negara, dan lain sebagainya.  Bidang Kajian memudahkan kamu untuk mencari tema apa yang ingin dijelajahi. Semakin baik kualitas bahasan seseorang pada sebuah Bidang Kajian, semakin tinggi pula kredibilitasnya pada topik tersebut. Ayo tunjukkan reputasimu yang sesungguhnya!"
                case .pernyataan:
                    self.lblTitle.text = "PERNYATAAN"
                    self.lblContent.text = "Rumusan pernyataan juga harus diperhatikan. Jangan sampai lawan debat kamu bingung dengan apa yang ingin dibahas. Gunakan tata bahasa yang baik dan jangan menyingkat kata-kata spy tdk mmbngngkn mslny sprt ini. Hmm…\n\nKamu bisa mengutip berita atau pernyataan seseorang sebagai bahan debat. Ingat! Harus tetap bertanggung jawab dengan materi debat, ya. Kualitas argumen dan fokus adalah kunci! Jaga debatnya biar nggak melebar ke mana-mana."
                case .dateTime:
                    self.lblTitle.text = "DATE & TIME"
                    self.lblContent.text = "Tanggal dan Waktu amat penting diperhatikan sebelum memulai atau menerima tantangan. Keduanya menunjukkan kesiapan kamu pada suatu saat tertentu. Tantangan akan dianggap kedaluarsa/expired jika melewati tanggal dan waktu yang disepakati.\n\nCoba pilih prakiraan waktu yang memungkinkan kamu dan lawan debatmu sama-sama tersedia. Jangan sampai uji argumentasimu terganggu karena salah momen :("
                case .saldoWaktu:
                    self.lblTitle.text = "SALDO WAKTU"
                    self.lblContent.text = "Durasi yang tersedia untuk peserta debat disebut Saldo Waktu. Masing-masing pihak memiliki kesempatan jumlah waktu yang sama. Keduanya perlu punya strategi khusus agar respons jawaban sekaligus pemahaman materi dilakukan dengan tepat, seksama, dan dalam tempo sesingkat-singkatnya. Siap-siap, yaa!"
                case .lawanDebat:
                    self.lblTitle.text = "LAWAN DEBAT"
                    self.lblContent.text = "Sebelum menantang debat, pastikan lawan kamu memiliki akun Twitter; bisa juga langsung mention namanya apabila sudah tercatat di akun Symbolic ID."
                }
            })
            .drive()
            .disposed(by: disposeBag)
    }
    
}
