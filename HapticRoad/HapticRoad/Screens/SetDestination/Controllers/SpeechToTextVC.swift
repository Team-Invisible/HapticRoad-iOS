//
//  SpeechToTextVC.swift
//  HapticRoad
//
//  Created by 황지은 on 2021/10/26.
//

import UIKit
import Speech

class SpeechToTextVC: UIViewController {

    //MARK: Properties
    //한국어 인식
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: "ko-KR"))
    //음성인식요청 처리 객체
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    //음성인식요청 결과 제공
    private var recognitionTask: SFSpeechRecognitionTask?
    //순수 소리만을 인식하는 오디오 엔진 객체
    private let audioEngine = AVAudioEngine()
    var sttText: String = ""
    var timer: Timer?
    
    @IBOutlet var guideLabel: UILabel!
    @IBOutlet var sttTextLabel: UILabel!
    @IBOutlet var speechBtn: UIButton!
    
    //MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        speechRecognizer?.delegate = self
        navigationController?.navigationBar.isHidden = true
    }
    
    //MARK: Custom Method
    func pushToNextVC() {
        guard let vc = self.storyboard?.instantiateViewController(withIdentifier: TextToSpeechVC.identifier) as? TextToSpeechVC else { return }
        vc.destString = sttText
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
//MARK: - SFSpeechRecognizerDelegate
extension SpeechToTextVC: SFSpeechRecognizerDelegate {
    
    @IBAction func sttBtnDidTap(_ sender: UIButton) {
        if audioEngine.isRunning {
            //현재 음성인식이 수행중이라면
            audioEngine.stop() //오디오 입력 중단
            recognitionRequest?.endAudio() //음성인식도 중단
        }
        else {
            startRecoding()
        }
    }
    
    func startRecoding() {
        //인식 작업이 실행 중인지 확인. 이 경우 작업과 인식을 취소
        //현재 음성인식을 처리하고 있으면 그 작업을 중지하고 새로운 음성인식처리를 하라는 부분
        //지금 음성인식을 시작했는데, 다른 음성인식을 처리하고있으면 현재 음성을 처리못하므로!
        
        if recognitionTask != nil {
            recognitionTask?.cancel()
            recognitionTask = nil
        }
        
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(AVAudioSession.Category.record)
            try audioSession.setMode(AVAudioSession.Mode.measurement)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print("audioSession properties weren't set because of an error.")
        }
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        
        let inputNode = audioEngine.inputNode
        
        guard let recognitionRequest = recognitionRequest else {
            fatalError("Unable to create an SFSpeechAudioBufferRecognitionRequest object")
        }
        
        recognitionRequest.shouldReportPartialResults = true
        
        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest, resultHandler: { [self] (result, error) in
            
            var isFinal = false
            
            if result != nil {
                self.guideLabel.text = "듣고 있어요"
                self.speechBtn.configuration?.background.image = UIImage(named: "hearingMotion")
                self.sttTextLabel.text = result?.bestTranscription.formattedString
                self.sttText = result?.bestTranscription.formattedString ?? "Default"
                print(sttText)
                isFinal = (result?.isFinal)!
                print(isFinal)
            }
            
            if error != nil || isFinal {
                self.audioEngine.stop()
                
                inputNode.removeTap(onBus: 0)
                
                self.recognitionRequest = nil
                self.recognitionTask = nil
                // 사용자의 음성이 멈추면 nextVC로 이동하도록 추후에 로직 변경하기.
                pushToNextVC()
            }
        })
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, when) in
            self.recognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()
        
        do {
            try audioEngine.start()
        }
        catch {
            print("audioEngine couldn't start because of an error.")
        }
    }
    
    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        if available {
            speechBtn.isEnabled = true
        }
        else {
            speechBtn.isEnabled = false
        }
    }
}
