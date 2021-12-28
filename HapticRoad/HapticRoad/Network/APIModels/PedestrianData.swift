//
//  PedestrianData.swift
//  HapticRoad
//
//  Created by 황지은 on 2021/12/05.
//

import Foundation
// MARK: - PedestrianData
struct PedestrianData: Codable {
    let type: String
    let geometry: Geometry
    let properties: Properties
}

// MARK: - Geometry
struct Geometry: Codable {
    let type: String
    let coordinates: [[Double]]?
}

//enum Coordinate: Codable {
//    case double(Double)
//    case doubleArray([Double])
//
//    init(from decoder: Decoder) throws {
//        let container = try decoder.singleValueContainer()
//        if let x = try? container.decode([Double].self) {
//            self = .doubleArray(x)
//            return
//        }
//        if let x = try? container.decode(Double.self) {
//            self = .double(x)
//            return
//        }
//        throw DecodingError.typeMismatch(Coordinate.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for Coordinate"))
//    }
//
//    func encode(to encoder: Encoder) throws {
//        var container = encoder.singleValueContainer()
//        switch self {
//        case .double(let x):
//            try container.encode(x)
//        case .doubleArray(let x):
//            try container.encode(x)
//        }
//    }
//}

// MARK: - Properties
struct Properties: Codable {
    let index: Int
    let pointIndex: Int?
    let name, propertiesDescription: String
    let direction, nearPoiName, nearPoiX, nearPoiY: String?
    let intersectionName: String?
    let facilityType, facilityName: String
    let turnType: Int?
    let pointType: String?
    let lineIndex, distance, time, roadType: Int?
    let categoryRoadType: Int?

    enum CodingKeys: String, CodingKey {
        case index, pointIndex, name
        case propertiesDescription = "description"
        case direction, nearPoiName, nearPoiX, nearPoiY, intersectionName, facilityType, facilityName, turnType, pointType, lineIndex, distance, time, roadType, categoryRoadType
    }
}
