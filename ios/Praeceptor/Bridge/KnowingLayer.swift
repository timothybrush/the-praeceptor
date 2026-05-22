import Foundation

@MainActor
final class KnowingLayerBridge: ObservableObject {
    @Published var knowingLayer: KnowingLayer?

    private let fileName = "praeceptor-knowing.json"
    private let iCloudContainer: URL?

    init() {
        iCloudContainer = FileManager.default
            .url(forUbiquityContainerIdentifier: nil)?
            .appendingPathComponent("Documents")
            ?? FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first

        load()
    }

    private var fileURL: URL? {
        iCloudContainer?.appendingPathComponent(fileName)
    }

    func load() {
        guard let url = fileURL,
              let data = try? Data(contentsOf: url),
              let layer = try? JSONDecoder().decode(KnowingLayer.self, from: data) else {
            knowingLayer = nil
            return
        }
        knowingLayer = layer
    }

    func save(_ layer: KnowingLayer) {
        knowingLayer = layer
        guard let url = fileURL,
              let data = try? JSONEncoder().encode(layer) else { return }
        // .completeFileProtection encrypts the file when the device is locked
        try? data.write(to: url, options: [.atomic, .completeFileProtection])
    }

    func reset() {
        knowingLayer = nil
        if let url = fileURL { try? FileManager.default.removeItem(at: url) }
    }

    var hasKnowingLayer: Bool { knowingLayer != nil }
}
