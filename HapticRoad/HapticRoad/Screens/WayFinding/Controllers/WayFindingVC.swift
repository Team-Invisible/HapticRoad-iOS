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
        
        TMapAPI.shared.getPedestrianRouteAPI(startX: 126.92365493654832, startY: 37.556770374096615, endX: 126.92432158129688, endY: 37.55279861528311, startName: "성북구청", endName: "성북구청") { (networkResult) -> (Void) in
            
            switch networkResult {
            case .success(let data):
                if let resultData = data as? PedestrianData {
                    print("hellllo", resultData)
                }
            case .requestErr(_):
                print("requesetErr")
            case .pathErr:
                print("pathErr")
            case .serverErr:
                print("serverErr")
            case .networkFail:
                print("networkFail")
            }
        }
    }
}
