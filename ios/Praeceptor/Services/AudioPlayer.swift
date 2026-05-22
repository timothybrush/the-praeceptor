import Foundation
import AVFoundation

@MainActor
final class AudioPlayer: NSObject, ObservableObject, AVAudioPlayerDelegate {
    @Published var isPlaying = false

    private var player: AVAudioPlayer?
    private var onComplete: (() -> Void)?

    func play(data: Data, onComplete: @escaping () -> Void) throws {
        self.onComplete = onComplete
        player = try AVAudioPlayer(data: data)
        player?.delegate = self
        player?.play()
        isPlaying = true
    }

    func stop() {
        player?.stop()
        player = nil
        isPlaying = false
        onComplete = nil
    }

    nonisolated func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        Task { @MainActor in
            self.isPlaying = false
            self.onComplete?()
            self.onComplete = nil
        }
    }
}
