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
    
    @IBOutlet var searchedAddressTV: UITableView! {
        didSet {
            searchedAddressTV.separatorStyle = .none
        }
    }
    @IBOutlet var destLabel: UILabel! {
        didSet {
            if let dest = destString {
                destLabel.text = "\(dest)에 대한\n정확한 주소를 선택해주세요"
                destLabel.numberOfLines = 0
                destLabel.sizeToFit()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        makeDelegate()
        registerNib()
    }
    
    func makeDelegate() {
        searchedAddressTV.dataSource = self
        searchedAddressTV.delegate = self
    }
    
    func registerNib() {
        let xibName = UINib(nibName: Identifiers.adressTVC, bundle: nil)
        searchedAddressTV.register(xibName, forCellReuseIdentifier: Identifiers.adressTVC)
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
//MARK: - UITableViewDataSource
extension TextToSpeechVC: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return searchedAddressData.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: Identifiers.adressTVC) as? AdressTVC else { return UITableViewCell() }
        cell.setAppData(appData: searchedAddressData[indexPath.row])
        return cell
    }
}
//MARK: - UITableViewDelegate
extension TextToSpeechVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 92
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        let view:UIView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: self.view.bounds.size.width, height: 10))
        view.backgroundColor = .clear
        
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 12
    }
}
