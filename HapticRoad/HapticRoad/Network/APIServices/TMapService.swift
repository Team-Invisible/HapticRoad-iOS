//
//  TMapService.swift
//  HapticRoad
//
//  Created by 황지은 on 2021/12/04.
//

import Foundation
import Moya

enum TMapService {
    case pedestrianRouteData(startX: Double, startY: Double, endX: Double, endY: Double, startName: String, endName: String)
    case poisData
}

extension TMapService: TargetType {
    var baseURL: URL {
        return URL(string: APIConstants.tmapBaseURL)!
    }
    
    var path: String {
        switch self {
            
        case .pedestrianRouteData:
            return "/routes/pedestrian"
        case .poisData:
            return "/pois"
        }
    }
    
    var method: Moya.Method {
        return .get
    }
    
    var task: Task {
        switch self {
            
        case .pedestrianRouteData(let startX, let startY, let endX, let endY, let startName, let endName):
            return .requestParameters(parameters: [
                "startX" : startX,
                "startY": startY,
                "endX": endX,
                "endY": endY,
                "startName": startName,
                "endName" : endName,
            ], encoding: URLEncoding.queryString)
        case .poisData:
            return .requestPlain
        }
    }
    
    var headers: [String : String]? {
        return ["Content-Type": "application/json",
                "appKey": "l7xxfc242ed17fd0469ea6bcd2c49459a99c"]
    }
}
