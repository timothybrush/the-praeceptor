import Foundation

@MainActor
final class LaunchState: ObservableObject {
    @Published var startRecording = false
}
