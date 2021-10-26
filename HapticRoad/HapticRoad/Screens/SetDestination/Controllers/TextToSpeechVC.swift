//
//  TextToSpeechVC.swift
//  HapticRoad
//
//  Created by 황지은 on 2021/10/26.
//

import UIKit
import AVFoundation

class TextToSpeechVC: UIViewController {
    
    static let identifier = "TextToSpeechVC"
    var destString: String?
    let synthesizer = AVSpeechSynthesizer()
    
    @IBOutlet var destLabel: UILabel! {
        didSet {
            if let dest = destString {
                destLabel.text = dest
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func tapToTextToSpeech(_ sender: UIButton) {
        
        do{
            let _ = try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback,
                                                                    options: .duckOthers)
            try AVAudioSession.sharedInstance().setActive(true)
            let utterance = AVSpeechUtterance(string: destLabel.text!)
            utterance.voice = AVSpeechSynthesisVoice(language: "ko-KR")
            utterance.rate = 0.4
            synthesizer.speak(utterance)
        }catch{
            print(error)
        }
    }
}
