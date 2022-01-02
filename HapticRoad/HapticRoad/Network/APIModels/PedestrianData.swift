//
//  PedestrianData.swift
//  HapticRoad
//
//  Created by 황지은 on 2021/12/05.
//

import Foundation
// MARK: - PedestrianData
struct PedestrianData: Codable {
    let pedestrian: [Pedestrian]
    let totalDistance, totalTime: Int
}

// MARK: - Pedestrian
struct Pedestrian: Codable {
    let type: TypeEnum
    var coordinates: [Double]
    let index: Int
    let pointIndex, lineIndex: Int?
    let name, pedestrianDescription: String
    let distance, time: Int?
    let direction: String?
    let facilityType, facilityName: String
    let turnType: Int?

    enum CodingKeys: String, CodingKey {
        case type, coordinates, index, pointIndex, lineIndex, name
        case pedestrianDescription = "description"
        case distance, time, direction, facilityType, facilityName, turnType
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        type = (try? values.decode(TypeEnum.self, forKey: .type)) ?? .lineString
        coordinates = (try? values.decode([Double].self, forKey: .coordinates)) ?? []
        index = (try? values.decode(Int.self, forKey: .index)) ?? -1
        pointIndex = (try? values.decode(Int.self, forKey: .pointIndex)) ?? -1
        lineIndex = (try? values.decode(Int.self, forKey: .lineIndex)) ?? -1
        name = (try? values.decode(String.self, forKey: .name)) ?? ""
        pedestrianDescription = (try? values.decode(String.self, forKey: .pedestrianDescription)) ?? ""
        distance = (try? values.decode(Int.self, forKey: .distance)) ?? -1
        time = (try? values.decode(Int.self, forKey: .time)) ?? -1
        direction = (try? values.decode(String.self, forKey: .direction)) ?? ""
        facilityType = (try? values.decode(String.self, forKey: .facilityType)) ?? ""
        facilityName = (try? values.decode(String.self, forKey: .facilityName)) ?? ""
        turnType = (try? values.decode(Int.self, forKey: .turnType)) ?? -1
    }
}

enum TypeEnum: String, Codable {
    case lineString = "LineString"
    case point = "Point"
}
