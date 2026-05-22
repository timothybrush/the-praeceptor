import Foundation
import AVFoundation

@MainActor
final class AudioRecorder: NSObject, ObservableObject {
    @Published var isRecording = false
    @Published var audioLevel: Float = 0

    private var recorder: AVAudioRecorder?
    private let outputURL: URL

    override init() {
        outputURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("praeceptor_recording.wav")
        super.init()
    }

    func start() throws {
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.playAndRecord, mode: .default, options: .defaultToSpeaker)
        try audioSession.setActive(true)

        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatLinearPCM),
            AVSampleRateKey: 16000,
            AVNumberOfChannelsKey: 1,
            AVLinearPCMBitDepthKey: 16,
            AVLinearPCMIsFloatKey: false,
            AVLinearPCMIsBigEndianKey: false
        ]
        recorder = try AVAudioRecorder(url: outputURL, settings: settings)
        recorder?.isMeteringEnabled = true
        recorder?.record()
        isRecording = true

        Task { @MainActor [weak self] in
            while self?.isRecording == true {
                self?.updateLevel()
                try? await Task.sleep(for: .milliseconds(50))
            }
        }
    }

    func stop() -> URL? {
        isRecording = false
        recorder?.stop()
        recorder = nil
        audioLevel = 0
        return outputURL
    }

    private func updateLevel() {
        recorder?.updateMeters()
        let db = recorder?.averagePower(forChannel: 0) ?? -160
        let normalized = max(0, min(1, (db + 60) / 60))
        audioLevel = normalized
    }
}
