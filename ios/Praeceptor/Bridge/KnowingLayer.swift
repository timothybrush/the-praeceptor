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

    // MARK: — Context Folder (Files app → On My iPhone → Praeceptor)

    var contextFolderURL: URL? {
        // Prefer iCloud if available; fall back to local Documents (visible in Files app)
        if let iCloudURL = FileManager.default
            .url(forUbiquityContainerIdentifier: nil)?
            .appendingPathComponent("Documents")
            .appendingPathComponent("Praeceptor") {
            try? FileManager.default.createDirectory(at: iCloudURL, withIntermediateDirectories: true)
            return iCloudURL
        }
        let local = FileManager.default
            .urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("Praeceptor")
        try? FileManager.default.createDirectory(at: local, withIntermediateDirectories: true)
        return local
    }

    var isUsingICloud: Bool {
        FileManager.default.url(forUbiquityContainerIdentifier: nil) != nil
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

    // MARK: — Copy Context Prompt for Claude Code

    static let claudeCodeContextPrompt = """
        I'm about to have a session with an ops mentor. Generate a plain-text context brief I can paste in — 200 words max. Cover: what I'm actively building right now, what I last committed to doing (check recent git commits, tasks, or notes), what I'm actually spending time on, and any friction or recurring blocker you can see. Pull from the codebase, git history, and any working context you have. First person. No headers. Just the brief.
        """
}
