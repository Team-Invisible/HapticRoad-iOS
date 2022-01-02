//
//  StartSetDestinationVC.swift
//  HapticRoad
//
//  Created by 황지은 on 2021/12/29.
//

import UIKit
import CoreLocation

class StartSetDestinationVC: UIViewController {
    
    var locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setLocationAuth()
    }
    
    //MARK: - IBAction
    @IBAction func startWayFindingBtnDidTap(_ sender: UIButton) {
        guard let vc = self.storyboard?.instantiateViewController(withIdentifier: Identifiers.speechToTextVC) as? SpeechToTextVC else { return }
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    @IBAction func stopWayFindingBtnDidTap(_ sender: UIButton) {
        print("stop")
    }
}

//MARK: - Location
extension StartSetDestinationVC: CLLocationManagerDelegate {
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
