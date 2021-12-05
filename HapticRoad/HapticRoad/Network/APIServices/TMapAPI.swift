//
//  TMapAPI.swift
//  HapticRoad
//
//  Created by 황지은 on 2021/12/04.
//

import Foundation
import Moya

class TMapAPI {
    static let shared = TMapAPI()
    var userProvider = MoyaProvider<TMapService>(plugins: [NetworkLoggerPlugin()])
    
    private init() {}
    
    //MARK: API
    func getPedestrianRouteAPI(startX: Double, startY: Double, endX: Double, endY: Double, startName: String, endName: String, completion: @escaping (NetworkResult<Any>) -> (Void)) {
        userProvider.request(.pedestrianRouteData(startX: startX, startY: startY, endX: endX, endY: endY, startName: startName, endName: endName)) { [self]
            result in
            switch result {
                
            case .success(let response):
                let statusCode = response.statusCode
                let data = response.data
                
                completion(getPedestrianRouteJudgeData(status: statusCode, data: data))
            case .failure(let err):
                print(err)
            }
        }
    }
    
    //MARK: judgeData
    func getPedestrianRouteJudgeData(status: Int, data: Data) -> NetworkResult<Any> {
        let decoder = JSONDecoder()
        guard let decodedData = try? decoder.decode(GenericResponse<PedestrianData>.self, from: data) else {
            return .pathErr }
        
        switch status {
        case 200:
            return .success(decodedData ?? "None-Data")
        case 400...500:
            return .requestErr(decodedData)
        case 500:
            return .serverErr
        default:
            return .networkFail
        }
    }
}
