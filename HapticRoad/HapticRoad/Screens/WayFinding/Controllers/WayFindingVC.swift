//
//  WayFinding.swift
//  HapticRoad
//
//  Created by 황지은 on 2021/09/26.
//

import UIKit

class WayFindingVC: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    @IBAction func getPedestrianData(_ sender: UIButton) {
        TMapAPI.shared.getPedestrianRouteAPI(startX: 126.92365493654832, startY: 37.556770374096615, endX: 126.92432158129688, endY: 37.55279861528311, startName: "%EC%B6%9C%EB%B0%9C", endName: "%EB%B3%B8%EC%82%AC") { networkResult in
            switch networkResult {
            case .success(let res):
                print("hello", res)
                if let data = res as? [PedestrianData] {
                    print(data)
                }
                print("success")
            case .requestErr(let msg):
                if let message = msg as? String {
                    print(message)
                }
            case .pathErr:
                print("여기야?")
                print("pathErr")
            case .serverErr:
                print("serverErr")
            case .networkFail:
                print("networkFail")
            }
        }
    }
}
