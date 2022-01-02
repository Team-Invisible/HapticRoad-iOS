//
//  PoiData.swift
//  HapticRoad
//
//  Created by 황지은 on 2021/12/31.
//

import Foundation
// MARK: - PoiData
struct PoiData: Codable {
    let list: [PoiList]
}

// MARK: - List
struct PoiList: Codable {
    let id, name, frontLat, frontLon: String
    let fullAddressRoad: String
}
