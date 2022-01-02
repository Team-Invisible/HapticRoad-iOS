//
//  AddressConfirmVC.swift
//  HapticRoad
//
//  Created by 황지은 on 2022/01/01.
//

import UIKit

class AddressConfirmVC: UIViewController {
    
    //MARK: Properties
    var addressName: String?
    var fullAddress: String?
    var takenTime: String?
    var distance: String?
    var crosswalkCount: Int?
    var endX: Double?
    var endY: Double?
    var endName: String?
    
    @IBOutlet var addressNameLabel: UILabel! {
        didSet {
            if let name = addressName {
                addressNameLabel.text = name
                addressNameLabel.sizeToFit()
            }
        }
    }
    
    @IBOutlet var fullAddressLabel: UILabel! {
        didSet {
            if let address  = fullAddress {
                fullAddressLabel.text = address
                fullAddressLabel.sizeToFit()
            }
        }
    }
    
    @IBOutlet var takenTimeLabel: UILabel! {
        didSet {
            takenTimeLabel.sizeToFit()
        }
    }
    
    @IBOutlet var walkCountLabel: UILabel! {
        didSet {
            walkCountLabel.sizeToFit()
        }
    }
    
    @IBOutlet var distanceLabel: UILabel! {
        didSet {
            distanceLabel.sizeToFit()
        }
    }
    
    @IBOutlet var crosswalkCountLabel: UILabel! {
        didSet {
            crosswalkCountLabel.sizeToFit()
        }
    }
    
    //MARK: Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        getPedestrianData(startX: Location.shared.longitude ?? -1, startY: Location.shared.latitude ?? -1, endX: endX ?? -1, endY: endY ?? -1, startName: "*", endName: endName ?? "")
    }
    
    //MARK: IBAction
    @IBAction func destinationYesBtnDidTap(_ sender: UIButton) {
        let wayfindingSB: UIStoryboard = UIStoryboard(name: Identifiers.wayFindingSB, bundle: nil)
        guard let wayfindingVC = wayfindingSB.instantiateViewController(withIdentifier: Identifiers.wayGuidanceVC) as? WayGuidanceVC else { return }
        
        wayfindingVC.modalTransitionStyle = .crossDissolve
        wayfindingVC.modalPresentationStyle = .fullScreen
        
        wayfindingVC.endX = endX
        wayfindingVC.endY = endY
        wayfindingVC.endName = endName
        wayfindingVC.addressName = addressName
        wayfindingVC.fullAddress = fullAddress
    
        self.present(wayfindingVC, animated: true, completion: nil)
    }
    
    @IBAction func destinationNoBtnDidTap(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
}

//MARK: - Custom Method
extension AddressConfirmVC {
    /// func - 초단위의 시간을 시,분,초로 변환
    func convertToHourTime(time: Int) -> String {
        let convertHourTime = time / 3600
        let convertMinuteTime = time / 60
        let convertSecondsTime = time % 60
        
        print(convertHourTime, convertMinuteTime, convertSecondsTime)
        
        if convertMinuteTime == 0 {
            return "\(convertSecondsTime)초"
        }
        else if convertHourTime == 0 {
            return "\(convertMinuteTime)분 \(convertSecondsTime)초"
        }
        else {
            return "\(convertHourTime)시간 \(convertMinuteTime)분 \(convertSecondsTime)초"
        }
    }
    
    /// func - 미터 단위의 거리를 미터 또는 킬로미터로 변환
    func convertMeterToKiloMeter(distance: Int) -> String {
        let convertKiloMeter = distance / 1000
        
        if convertKiloMeter == 0 {
            return "\(distance)m"
        }
        else {
            return "\(convertKiloMeter)km"
        }
    }
    
    /// func - 신호등 개수 카운트
    func calculateCrosswalkCount(data: [Pedestrian]) -> Int {
        var crosswalkCount: Int = 0
        for i in 0..<data.count {
            if data[i].turnType == 211 || data[i].turnType == 212 || data[i].turnType == 213 {
                crosswalkCount += 1
            }
        }
        return crosswalkCount
    }
}

//MARK: - Network
extension AddressConfirmVC {
    func getPedestrianData(startX: Double, startY: Double, endX: Double, endY: Double, startName: String, endName: String) {
        TMapAPI.shared.getPedestrianRouteAPI(startX: startX, startY: startY, endX: endX, endY: endY, startName: startName, endName: endName) { (networkResult) -> (Void) in
            
            switch networkResult {
            case .success(let data):
                if let resultData = data as? PedestrianData {
                    print(resultData)
                    DispatchQueue.main.async {
                        self.takenTimeLabel.text = self.convertToHourTime(time: resultData.totalTime)
                        self.distanceLabel.text = self.convertMeterToKiloMeter(distance: resultData.totalDistance)
                        self.crosswalkCountLabel.text = "횡단보도 \(String(describing: self.calculateCrosswalkCount(data: resultData.pedestrian)))"
                    }
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
