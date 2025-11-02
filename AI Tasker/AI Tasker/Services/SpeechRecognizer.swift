import Speech
import AVFoundation
import Foundation

class SpeechRecognizer: NSObject, SFSpeechRecognizerDelegate {
    static let shared = SpeechRecognizer()

    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()

    var isAvailable: Bool {
        speechRecognizer?.isAvailable ?? false
    }

    override init() {
        super.init()
        speechRecognizer?.delegate = self
    }

    // MARK: - Speech Recognition

    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        SFSpeechRecognizer.requestAuthorization { authStatus in
            DispatchQueue.main.async {
                completion(authStatus == .authorized)
            }
        }
    }

    func startRecording(completion: @escaping (String?, Error?) -> Void) {
        // Check authorization
        SFSpeechRecognizer.requestAuthorization { authStatus in
            guard authStatus == .authorized else {
                completion(nil, SpeechRecognitionError.notAuthorized)
                return
            }

            DispatchQueue.main.async {
                do {
                    // Stop any previous recording
                    self.stopRecording()

                    let audioSession = AVAudioSession.sharedInstance()
                    try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
                    try audioSession.setActive(true, options: .notifyOthersOnDeactivation)

                    let inputNode = self.audioEngine.inputNode
                    let recordingFormat = inputNode.outputFormat(forBus: 0)

                    let request = SFSpeechAudioBufferRecognitionRequest()
                    request.shouldReportPartialResults = true

                    inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
                        request.append(buffer)
                    }

                    self.audioEngine.prepare()
                    try self.audioEngine.start()

                    self.recognitionTask = self.speechRecognizer?.recognitionTask(with: request) { result, error in
                        var isFinal = false

                        if let result = result {
                            completion(result.bestTranscription.formattedString, nil)
                            isFinal = result.isFinal
                        }

                        if error != nil || isFinal {
                            self.audioEngine.stop()
                            inputNode.removeTap(onBus: 0)
                            self.recognitionTask?.finish()
                        }
                    }
                } catch {
                    completion(nil, error)
                }
            }
        }
    }

    func stopRecording() {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        recognitionTask?.finish()
        recognitionTask = nil
    }

    // MARK: - SFSpeechRecognizerDelegate

    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        // Handle availability changes
    }
}

// MARK: - Error Handling

enum SpeechRecognitionError: LocalizedError {
    case notAuthorized
    case audioEngineError
    case recognitionError(String)

    var errorDescription: String? {
        switch self {
        case .notAuthorized:
            return "Speech recognition is not authorized. Please enable it in Settings."
        case .audioEngineError:
            return "Audio engine encountered an error."
        case .recognitionError(let message):
            return "Recognition error: \(message)"
        }
    }
}
