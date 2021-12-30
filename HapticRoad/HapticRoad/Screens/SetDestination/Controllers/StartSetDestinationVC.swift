//
//  StartSetDestinationVC.swift
//  HapticRoad
//
//  Created by 황지은 on 2021/12/29.
//

import UIKit

class StartSetDestinationVC: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
