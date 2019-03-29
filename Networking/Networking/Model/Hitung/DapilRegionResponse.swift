//
//  DapilRegionResponse.swift
//  Networking
//
//  Created by Hanif Sugiyanto on 29/03/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import Foundation

public enum TingkatDapil: String, Codable {
    case dpr = "dpr"
    case provinsi = "provinsi"
    case kabupaten = "kabupaten"
    case dpd = "dpd"
}

public struct DapilRegionResponse: Codable {
    
    public let id: Int
    public let nama: String
    public let tingkat: TingkatDapil
    public let jumlahPenduduk: Int?
    public let idWilayah: Int?
    public let totalAlokasiKursi: Int?
    public let idVersi: Int?
    public let noDapil: Int?
    public let statusCoterminous: Bool
    public let idPro: Int?
    public let parent: Int?
    public let alokasiKursi: Int?
    public let sisaPenduduk: Int?
    public let peringkatPenduduk: Int?
    public let alokasiSisaKursi: Int?
    public let stdDev: Int?
    public let mean: Int?
    public let maxAlokasiKursi: Int?
    public let minAlokasiKursi: Int?
    
}
