//
//  SummaryC1Response.swift
//  Networking
//
//  Created by Hanif Sugiyanto on 09/04/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import Foundation

public struct SummaryC1Response: Codable {
    public let formC1: C1Response
    
    private enum CodingKeys: String, CodingKey {
        case formC1 = "form_c1"
    }
}


public struct C1Response: Codable {
    public let createdAt: String
    public let createdInWord: CreatedInWord
    public let id: String
    public let realCount: RealCount
    public let hitungRealCountId: String
    public let type: String
    public let a3Laki: Int
    public let a3Perempuan: Int
    public let a4Laki: Int
    public let a4Perempuan: Int
    public let aDpkLaki: Int
    public let aDpkPerempuan: Int
    public let c7DptLaki: Int
    public let c7DptPerempuan: Int
    public let c7DptbLaki: Int
    public let c7DptbPerempuan: Int
    public let c7DpkLaki: Int
    public let c7DpkPerempuan: Int
    public let disabilitasTerdaftarLaki: Int
    public let disabilitasTerdaftarPerempuan: Int
    public let disabilitiasHakPilihLaki: Int
    public let disabilitasHakPilihPerempuan: Int
    public let suratDikembalikan: Int
    public let suratTidakDigunakan: Int
    public let suratDigunakan: Int
    public let aggregates: Aggregates
    
    private enum CodingKeys: String, CodingKey {
        case aggregates, id
        case createdAt = "created_at"
        case createdInWord = "created_at_in_word"
        case realCount = "real_count"
        case hitungRealCountId = "hitung_real_count_id"
        case type = "form_c1_type"
        case a3Laki = "a3_laki_laki"
        case a3Perempuan = "a3_perempuan"
        case a4Laki = "a4_laki_laki"
        case a4Perempuan = "a4_perempuan"
        case aDpkLaki = "a_dpk_laki_laki"
        case aDpkPerempuan = "a_dpk_perempuan"
        case c7DptLaki = "c7_dpt_laki_laki"
        case c7DptPerempuan = "c7_dpt_perempuan"
        case c7DptbLaki = "c7_dptb_laki_laki"
        case c7DptbPerempuan = "c7_dptb_perempuan"
        case c7DpkLaki = "c7_dpk_laki_laki"
        case c7DpkPerempuan = "c7_dpk_perempuan"
        case disabilitasTerdaftarLaki = "disabilitas_terdaftar_laki_laki"
        case disabilitasTerdaftarPerempuan = "disabilitas_terdaftar_perempuan"
        case disabilitiasHakPilihLaki = "disabilitas_hak_pilih_laki_laki"
        case disabilitasHakPilihPerempuan = "disabilitas_hak_pilih_perempuan"
        case suratDikembalikan = "surat_dikembalikan"
        case suratTidakDigunakan = "surat_tidak_digunakan"
        case suratDigunakan = "surat_digunakan"
    }
}

public struct Aggregates: Codable {
    public let a3Total: Int
    public let a4Total: Int
    public let aDpkTotal: Int
    public let pemilihLakiTotal: Int
    public let pemilihPerempuanTotal: Int
    public let pemilihTotal: Int
    public let c7DptTotal: Int
    public let c7dptbTotal: Int
    public let c7dpkTotal: Int
    public let c7LakiHakPilihTotal: Int
    public let c7PerempuanHakPilihTotal: Int
    public let c7HakPilihTotal: Int
    public let disabilitasTerdaftarTotal: Int
    public let disabilitasHakPilihTotal: Int
    public let totalSuara: Int
    
    private enum CodingKeys: String, CodingKey {
        case a3Total = "a3_total"
        case a4Total = "a4_total"
        case aDpkTotal = "a_dpk_total"
        case pemilihLakiTotal = "pemilih_laki_laki_total"
        case pemilihPerempuanTotal = "pemilih_perempuan_total"
        case pemilihTotal = "pemilih_total"
        case c7DptTotal = "c7_dpt_total"
        case c7dptbTotal = "c7_dptb_total"
        case c7dpkTotal = "c7_dpk_total"
        case c7LakiHakPilihTotal = "c7_laki_laki_hak_pilih_total"
        case c7PerempuanHakPilihTotal = "c7_perempuan_hak_pilih_total"
        case c7HakPilihTotal = "c7_hak_pilih_total"
        case disabilitasTerdaftarTotal = "disabilitas_terdaftar_total"
        case disabilitasHakPilihTotal = "disabilitas_hak_pilih_total"
        case totalSuara = "total_suara"
    }
}
