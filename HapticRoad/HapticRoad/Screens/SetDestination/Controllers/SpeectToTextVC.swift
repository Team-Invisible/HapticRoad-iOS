//
//  SpeectToTextVC.swift
//  HapticRoad
//
//  Created by 황지은 on 2021/10/26.
//

import UIKit
import Speech

class SpeectToTextVC: UIViewController {

    //Mark: - Properties
    //한국어 인식
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: "ko-KR"))
    //음성인식요청 처리 객체
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    //음성인식요청 결과 제공
    private var recognitionTask: SFSpeechRecognitionTask?
    //순수 소리만을 인식하는 오디오 엔진 객체
    private let audioEngine = AVAudioEngine()
    var sttText: String = ""
    
    @IBOutlet var speechBtn: UIButton!
    @IBOutlet var sttTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        speechRecognizer?.delegate = self
    }
}

extension SpeectToTextVC: SFSpeechRecognizerDelegate {
    
    
    @IBAction func tapToSpeechToText(_ sender: Any) {
        if audioEngine.isRunning {
            //현재 음성인식이 수행중이라면
            audioEngine.stop() //오디오 입력 중단
            recognitionRequest?.endAudio() //음성인식도 중단
            speechBtn.isEnabled = false
            speechBtn.setTitle("목적지 말하기", for: .normal)
        }
        else {
            startRecoding()
            speechBtn.setTitle("말하기 중단", for: .normal)
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
                
                self.sttTextView.text = result?.bestTranscription.formattedString
                sttText = result?.bestTranscription.formattedString ?? "Default"
                print(sttText)
                isFinal = (result?.isFinal)!
            }
            
            if error != nil || isFinal {
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                
                self.recognitionRequest = nil
                self.recognitionTask = nil
                
                self.speechBtn.isEnabled = true
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
        
        sttTextView.text = "계속 말하세요! 듣고 있어요"
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
