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

    // MARK: — Supplemental Context

    func updateSupplementalContext(_ text: String) {
        guard var layer = knowingLayer else { return }
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        layer.supplementalContext = trimmed.isEmpty ? nil : String(trimmed.prefix(KnowingLayer.supplementalContextLimit))
        save(layer)
    }

    func clearSupplementalContext() {
        guard var layer = knowingLayer else { return }
        layer.supplementalContext = nil
        save(layer)
    }

    // MARK: — iCloud Context Folder

    var contextFolderURL: URL? {
        FileManager.default
            .url(forUbiquityContainerIdentifier: nil)?
            .appendingPathComponent("Documents")
            .appendingPathComponent("Praeceptor")
    }

    func scanICloudContextFolder() -> String? {
        guard let folder = contextFolderURL else { return nil }
        let fm = FileManager.default
        guard let files = try? fm.contentsOfDirectory(at: folder, includingPropertiesForKeys: nil)
            .filter({ ["txt", "json"].contains($0.pathExtension.lowercased()) })
            .sorted(by: { $0.lastPathComponent < $1.lastPathComponent })
        else { return nil }
        guard !files.isEmpty else { return nil }
        let combined = files.compactMap { try? String(contentsOf: $0, encoding: .utf8) }
            .joined(separator: "\n\n---\n\n")
        return combined.isEmpty ? nil : combined
    }
}
