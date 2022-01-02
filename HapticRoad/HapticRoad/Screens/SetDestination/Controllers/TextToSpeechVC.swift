//
//  TextToSpeechVC.swift
//  HapticRoad
//
//  Created by 황지은 on 2021/10/26.
//

import UIKit
import CoreLocation
import AVFoundation
import Speech

class TextToSpeechVC: UIViewController {
    
    static let identifier = "TextToSpeechVC"
    var destString: String?
    let synthesizer = AVSpeechSynthesizer()
    var searchedData: [PoiList] = []
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private let audioEngine = AVAudioEngine()
    let audioSession = AVAudioSession.sharedInstance()
    
    @IBOutlet var searchedAddressTV: UITableView! {
        didSet {
            searchedAddressTV.separatorStyle = .none
            searchedAddressTV.isScrollEnabled = false
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
    
    @IBOutlet var popBtn: UIButton! {
        didSet {
            popBtn.isHidden = true
            popBtn.layer.cornerRadius = 12
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        accessibilityActivate()
        makeDelegate()
        registerNib()
        print("longitude: \(String(describing: Location.shared.longitude))")
        print("latitude: \(String(describing: Location.shared.latitude))")
        getPoiData(searchKeyword: destString ?? "", centerLon: Location.shared.longitude ?? 0, centerLat: Location.shared.latitude ?? 0)
        do {
            try audioSession.setCategory(AVAudioSession.Category.playback)
            try audioSession.setMode(AVAudioSession.Mode.measurement)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print("audioSession properties weren't set because of an error.")
        }
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
    
    @IBAction func popBtnDidTap(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    private func stopRecording() {
        let inputNode = audioEngine.inputNode
        audioEngine.stop()
        recognitionRequest?.endAudio()
        inputNode.removeTap(onBus: 0)
    }
}
//MARK: - UITableViewDataSource
extension TextToSpeechVC: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return searchedData.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: Identifiers.adressTVC) as? AdressTVC else { return UITableViewCell() }
        cell.setAppData(appData: searchedData[indexPath.section])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let vc = self.storyboard?.instantiateViewController(withIdentifier: Identifiers.addressConfirmVC) as? AddressConfirmVC else { return }
        
        vc.addressName = searchedData[indexPath.section].name
        vc.fullAddress = searchedData[indexPath.section].fullAddressRoad
        vc.endX = Double(searchedData[indexPath.section].frontLon)
        vc.endY = Double(searchedData[indexPath.section].frontLat)
        vc.endName = destString
        
        self.navigationController?.pushViewController(vc, animated: true)
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

//MARK: - Network
extension TextToSpeechVC {
    func getPoiData(searchKeyword: String, centerLon: Double, centerLat: Double) {
        TMapAPI.shared.getPoiAPI(searchKeyword: searchKeyword, centerLon: centerLon, centerLat: centerLat) { networkResult in
            switch networkResult {
            case .success(let res):
                if let data = res as? PoiData {
                    self.searchedData = data.list
                    print(self.searchedData)
                    if self.searchedData.count == 0 {
                        print("jj")
                        self.popBtn.isHidden = false
                    }
                    DispatchQueue.main.async {
                        self.searchedAddressTV.reloadData()
                    }
                }
            case .requestErr(let msg):
                if let message = msg as? String {
                    print(message)
                    self.popBtn.isHidden = false
                }
            case .pathErr:
                print("pathErr")
                self.popBtn.isHidden = false
            case .serverErr:
                print("serverErr")
                self.popBtn.isHidden = false
            case .networkFail:
                print("networkFail")
                self.popBtn.isHidden = false
            }
        }
    }
}
