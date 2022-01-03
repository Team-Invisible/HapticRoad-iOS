//
//  WayGuidanceVC.swift
//  HapticRoad
//
//  Created by 황지은 on 2022/01/01.
//

import UIKit
import CoreLocation
import CoreHaptics

enum guidanceType {
    case straight
    case left
    case right
    case crossWalk
}

class WayGuidanceVC: UIViewController {
    
    var pedestrianArray: [Pedestrian] = []
    var locationManager = CLLocationManager()
    var guidanceDirection: guidanceType?
    var guidanceTimer: Timer?
    var destCoordinate: CLLocation?
    var tempCoordinate: CLLocation? //목적지까지 가는 동안 가변적으로 변할 위/경도
    var addressName: String?
    var fullAddress: String?
    var endX: Double?
    var endY: Double?
    var endName: String?
    var currentIdx: Int = 0
    var engine: CHHapticEngine?
    
    @IBOutlet var guidanceImageView: UIImageView! {
        didSet {
            guidanceImageView.contentMode = .scaleAspectFill
        }
    }
    
    @IBOutlet var destinationNameLabel: UILabel! {
        didSet {
            destinationNameLabel.text = addressName
            destinationNameLabel.sizeToFit()
        }
    }
    
    @IBOutlet var destinationFullAddressLabel: UILabel! {
        didSet {
            destinationFullAddressLabel.text = fullAddress
            destinationFullAddressLabel.sizeToFit()
        }
    }
    
    @IBOutlet var detailGuidanceLabel: UILabel! {
        didSet {
            detailGuidanceLabel.sizeToFit()
        }
    }
    
    @IBOutlet var detailDistanceLabel: UILabel! {
        didSet {
            detailDistanceLabel.sizeToFit()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setCoordinate()
        hapticInitialSetting()
        getPedestrianData(startX: Location.shared.longitude ?? -1, startY: Location.shared.latitude ?? -1, endX: endX ?? -1, endY: endY ?? -1, startName: "*", endName: endName ?? "")
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        guidanceTimer?.invalidate()
    }
}

//MARK: - UI
extension WayGuidanceVC {
    /// func - 세부 가이드 UI
    func setDetailGuidanceUI(arrayIndex: Int) {
        detailGuidanceLabel.text = pedestrianArray[arrayIndex].pedestrianDescription
        
        let distance = pedestrianArray[arrayIndex].distance!
        if (distance < 0) {
            detailDistanceLabel.text = ""
        }
        else {
            detailDistanceLabel.text = "\(distance)m"
        }
    }
}

//MARK: - Custom Methods
extension WayGuidanceVC {
    
    /// func - Coordinate 초기 설정
    func setCoordinate() {
        destCoordinate = CLLocation(latitude: endX ?? -1, longitude: endY ?? -1)
        tempCoordinate = CLLocation(latitude: Location.shared.latitude ?? -1, longitude: Location.shared.longitude ?? -1)
    }
    
    @objc
    func circuitPedestrianArray() {
        // 오차범위 계산
        
        //1 이동 하고있는 tempLocation과 현재 인덱스의 cllocationArray를 비교
        if currentIdx != pedestrianArray.count - 1 {
            setLocationAuth()
            setCoordinate()
            
            let guidanceLongitude = pedestrianArray[currentIdx].coordinates[0]
            let guidanceLatitude = pedestrianArray[currentIdx].coordinates[1]
            
            //2 turnType 분기처리를 통해 적절한 햅틱, 안내 imageView 띄우기
            setDetailGuidanceUI(arrayIndex: currentIdx)
            matchTurntype(arrayIndex: currentIdx)
            
            if pedestrianArray[currentIdx].type == .point {
                currentIdx += 1
            }
            
            let distance = tempCoordinate?.distance(from: CLLocation(latitude: guidanceLatitude, longitude: guidanceLongitude)) ?? -1
            
            //3 비교 후 오차 범위 안에 진입했다면 인덱스 +1 & 다음 경로안내로 changing
            
            // 5m 보다 거리 차이가 나면
            print(distance)
            if distance > 2 {
                print("2m 보다 거리 차이가 나")
            }
            // 2m 보다 거리 차이가 안나면 == 오차범위 충족
            else {
                print("제대로 가고있어")
                currentIdx += 1
            }
            
            print("currentIdx: \(currentIdx)")
            print("currentDegree: \(tempCoordinate)")
        }
        else {
            //4 마지막 인덱스에 도달했을 때 도착 vc로 뷰 이동
            guard let arriveVC = self.storyboard?.instantiateViewController(withIdentifier: Identifiers.arrivedVC) as? ArrivedVC else { return }
            
            arriveVC.modalTransitionStyle = .crossDissolve
            arriveVC.modalPresentationStyle = .fullScreen
            
            self.present(arriveVC, animated: true, completion: {
                self.guidanceTimer?.invalidate()
            })
        }
    }
    
    /// func - turnType별 guide 방향 setting && 진동 기능
    func matchTurntype(arrayIndex: Int) {
        switch pedestrianArray[arrayIndex].turnType {
        case 11:
            guidanceDirection = .straight
            guidanceImageView.image = UIImage(named: "forward")
            print("forward")
        case 12:
            makeLeftHaptic()
            guidanceDirection = .left
            guidanceImageView.image = UIImage(named: "leftSide")
            print("leftSide")
        case 13:
            makeRightHaptic()
            guidanceDirection = .right
            guidanceImageView.image = UIImage(named: "rightSide")
            print("rightSide")
        case 211,212,213:
            makeCrossWalkHaptic()
            guidanceDirection = .crossWalk
            guidanceImageView.image = UIImage(named: "crosswalk")
            print("crosswalk")
        default:
            guidanceDirection = .straight
            guidanceImageView.image = UIImage(named: "forward")
            print("forward")
        }
    }
}

//MARK: - Network
extension WayGuidanceVC {
    
    func getPedestrianData(startX: Double, startY: Double, endX: Double, endY: Double, startName: String, endName: String) {
        TMapAPI.shared.getPedestrianRouteAPI(startX: startX, startY: startY, endX: endX, endY: endY, startName: startName, endName: endName) { [self] (networkResult) -> (Void) in
            
            switch networkResult {
            case .success(let data):
                if let resultData = data as? PedestrianData {
                    self.pedestrianArray = resultData.pedestrian
                    
                    matchTurntype(arrayIndex: 0)
                    setDetailGuidanceUI(arrayIndex: 0)
                    guidanceTimer = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(circuitPedestrianArray), userInfo: nil, repeats: true)
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

//MARK: - CLLocationManagerDelegate
extension WayGuidanceVC: CLLocationManagerDelegate  {
    func setLocationAuth() {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            print("위치 서비스 On 상태")
            locationManager.startUpdatingLocation()
            
            let coor = locationManager.location?.coordinate
            Location.shared.longitude = coor?.longitude
            Location.shared.latitude = coor?.latitude
        } else {
            print("위치 서비스 Off 상태")
        }
    }
}

//MARK: - Haptic
extension WayGuidanceVC {
    func hapticInitialSetting() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        
        do {
            engine = try CHHapticEngine()
            try engine?.start()
        } catch {
            print("There was an error creating the engine: \(error.localizedDescription)")
        }
        
        engine?.stoppedHandler = { reason in
            print("The engine stopped: \(reason)")
        }
        
        engine?.resetHandler = { [weak self] in
            print("The engine reset")
            
            do {
                try self?.engine?.start()
            } catch {
                print("Failed to restart the engine: \(error)")
            }
        }
    }
    
    func makeStraightHaptic() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        let short1 = CHHapticEvent(eventType: .hapticTransient, parameters: [], relativeTime: 0)
        let short2 = CHHapticEvent(eventType: .hapticTransient, parameters: [], relativeTime: 0.2)
        let short3 = CHHapticEvent(eventType: .hapticTransient, parameters: [], relativeTime: 0.4)
        let long1 = CHHapticEvent(eventType: .hapticContinuous, parameters: [], relativeTime: 0.6, duration: 0.5)
        let long2 = CHHapticEvent(eventType: .hapticContinuous, parameters: [], relativeTime: 1.2, duration: 0.5)
        let long3 = CHHapticEvent(eventType: .hapticContinuous, parameters: [], relativeTime: 1.8, duration: 0.5)
        let short4 = CHHapticEvent(eventType: .hapticTransient, parameters: [], relativeTime: 2.4)
        let short5 = CHHapticEvent(eventType: .hapticTransient, parameters: [], relativeTime: 2.6)
        let short6 = CHHapticEvent(eventType: .hapticTransient, parameters: [], relativeTime: 2.8)
        
        do {
            let pattern = try CHHapticPattern(events: [short1, short2, short3, long1, long2, long3, short4, short5, short6], parameters: [])
            let player = try engine?.makePlayer(with: pattern)
            try player?.start(atTime: 0)
        } catch {
            print("Failed to play pattern: \(error.localizedDescription).")
        }
        
    }
    
    func makeLeftHaptic() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        let long1 = CHHapticEvent(eventType: .hapticContinuous, parameters: [], relativeTime: 1.8, duration: 1.0)
        let long2 = CHHapticEvent(eventType: .hapticContinuous, parameters: [], relativeTime: 1.8, duration: 1.0)
        let long3 = CHHapticEvent(eventType: .hapticContinuous, parameters: [], relativeTime: 1.8, duration: 1.0)
        
        do {
            let pattern = try CHHapticPattern(events: [long1, long2, long3], parameters: [])
            let player = try engine?.makePlayer(with: pattern)
            try player?.start(atTime: 0)
        } catch {
            print("Failed to play pattern: \(error.localizedDescription).")
        }
        
    }
    
    func makeRightHaptic() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        let short1 = CHHapticEvent(eventType: .hapticTransient, parameters: [], relativeTime: 0)
        let short2 = CHHapticEvent(eventType: .hapticTransient, parameters: [], relativeTime: 0.2)
        let short3 = CHHapticEvent(eventType: .hapticTransient, parameters: [], relativeTime: 0.4)
        let short4 = CHHapticEvent(eventType: .hapticTransient, parameters: [], relativeTime: 2.4)
        let short5 = CHHapticEvent(eventType: .hapticTransient, parameters: [], relativeTime: 2.6)
        let short6 = CHHapticEvent(eventType: .hapticTransient, parameters: [], relativeTime: 2.8)
        
        do {
            let pattern = try CHHapticPattern(events: [short1, short2, short3, short4, short5, short6], parameters: [])
            let player = try engine?.makePlayer(with: pattern)
            try player?.start(atTime: 0)
        } catch {
            print("Failed to play pattern: \(error.localizedDescription).")
        }
        
    }
    
    func makeCrossWalkHaptic() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        
        let short1 = CHHapticEvent(eventType: .hapticTransient, parameters: [], relativeTime: 0)
        let short2 = CHHapticEvent(eventType: .hapticTransient, parameters: [], relativeTime: 0.2)
        let short3 = CHHapticEvent(eventType: .hapticTransient, parameters: [], relativeTime: 0.4)
        let long1 = CHHapticEvent(eventType: .hapticContinuous, parameters: [], relativeTime: 0.6, duration: 0.5)
        let long2 = CHHapticEvent(eventType: .hapticContinuous, parameters: [], relativeTime: 1.2, duration: 0.5)
        let long3 = CHHapticEvent(eventType: .hapticContinuous, parameters: [], relativeTime: 1.8, duration: 0.5)
        let short4 = CHHapticEvent(eventType: .hapticTransient, parameters: [], relativeTime: 2.4)
        let short5 = CHHapticEvent(eventType: .hapticTransient, parameters: [], relativeTime: 2.6)
        let short6 = CHHapticEvent(eventType: .hapticTransient, parameters: [], relativeTime: 2.8)
        
        do {
            let pattern = try CHHapticPattern(events: [short1, short2, short3, long1, long2, long3, short4, short5, short6], parameters: [])
            let player = try engine?.makePlayer(with: pattern)
            try player?.start(atTime: 0)
        } catch {
            print("Failed to play pattern: \(error.localizedDescription).")
        }
    }
}
