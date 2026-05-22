import Foundation
import AVFoundation

@MainActor
final class AudioRecorder: NSObject, ObservableObject {
    @Published var isRecording = false
    @Published var audioLevel: Float = 0

    private var recorder: AVAudioRecorder?
    private var levelTimer: Timer?
    private let outputURL: URL

    override init() {
        outputURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("praeceptor_recording.wav")
        super.init()
    }

    func start() throws {
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

        levelTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.updateLevel()
            }
        }
    }

    func stop() -> URL? {
        levelTimer?.invalidate()
        levelTimer = nil
        recorder?.stop()
        recorder = nil
        isRecording = false
        audioLevel = 0
        return outputURL
    }

    private func updateLevel() {
        recorder?.updateMeters()
        let db = recorder?.averagePower(forChannel: 0) ?? -160
        // Normalize -60dB..0dB → 0..1
        let normalized = max(0, min(1, (db + 60) / 60))
        audioLevel = normalized
    }
}
