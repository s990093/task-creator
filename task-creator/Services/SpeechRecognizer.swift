import Foundation
import Speech
import AVFoundation
import SwiftUI

class SpeechRecognizer: ObservableObject {
    @Published var transcript: String = ""
    @Published var isRecording: Bool = false
    @Published var error: String?
    
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "zh-TW")) // Default to Traditional Chinese
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    
    init() {
        requestSpeechAuthorization()
        requestMicrophoneAuthorization()
    }
    
    private func requestSpeechAuthorization() {
        SFSpeechRecognizer.requestAuthorization { authStatus in
            DispatchQueue.main.async {
                switch authStatus {
                case .authorized:
                    break
                case .denied:
                    self.error = "使用者未授權語音辨識"
                case .restricted:
                    self.error = "此裝置限制語音辨識"
                case .notDetermined:
                    self.error = "語音辨識尚未授權"
                @unknown default:
                    self.error = "未知授權狀態"
                }
            }
        }
    }
    
    private func requestMicrophoneAuthorization() {
        AVAudioSession.sharedInstance().requestRecordPermission { allowed in
            DispatchQueue.main.async {
                if !allowed {
                    self.error = "使用者未授權麥克風存取"
                }
            }
        }
    }
    
    func startTranscribing() {
        guard !isRecording else { return }
        
        // Reset error
        error = nil
        
        // Cancel previous task if any
        if recognitionTask != nil {
            recognitionTask?.cancel()
            recognitionTask = nil
        }
        
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            self.error = "無法設定音訊工作階段: \(error.localizedDescription)"
            return
        }
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        
        let inputNode = audioEngine.inputNode
        guard let recognitionRequest = recognitionRequest else {
            self.error = "無法建立辨識請求"
            return
        }
        
        recognitionRequest.shouldReportPartialResults = true
        
        // Keep a weak reference to self to avoid retain cycles
        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest) { [weak self] result, error in
            guard let self = self else { return }
            
            var isFinal = false
            
            if let result = result {
                self.transcript = result.bestTranscription.formattedString
                isFinal = result.isFinal
            }
            
            if error != nil || isFinal {
                self.stopTranscribing()
            }
        }
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, when) in
            self.recognitionRequest?.append(buffer)
        }
        
        do {
            try audioEngine.start()
            isRecording = true
        } catch {
            self.error = "無法啟動音訊引擎: \(error.localizedDescription)"
        }
    }
    
    func stopTranscribing() {
        if isRecording {
            audioEngine.stop()
            audioEngine.inputNode.removeTap(onBus: 0)
            recognitionRequest?.endAudio()
            isRecording = false
        }
    }
    
    func reset() {
        stopTranscribing()
        transcript = ""
        error = nil
    }
}
