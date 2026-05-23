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

    // MARK: — Copy Context for Claude Code

    func copyContextPrompt() -> String {
        guard let layer = knowingLayer else {
            return "No context available. Complete intake first."
        }

        var lines: [String] = []
        let name = layer.person.name.isEmpty ? "Operator" : layer.person.name
        lines.append("Operator: \(name)")
        if !layer.person.primaryMission.isEmpty {
            lines.append("Building: \(layer.person.primaryMission)")
        }
        if !layer.person.sovereigntyStage.isEmpty {
            lines.append("Stage: \(layer.person.sovereigntyStage)")
        }
        if !layer.person.originalThesis.isEmpty {
            lines.append("Original thesis: \(layer.person.originalThesis)")
        }

        lines.append("")

        let focus = layer.currentState.activeProject.isEmpty
            ? layer.currentState.whatTheyAreDoing
            : layer.currentState.activeProject
        if !focus.isEmpty {
            lines.append("Current focus: \(focus)")
        }
        if !layer.currentState.whatTheySaidTheyWouldDo.isEmpty {
            lines.append("Last commitment: \(layer.currentState.whatTheySaidTheyWouldDo)")
        }
        if !layer.currentState.whatTheyAreDoing.isEmpty && layer.currentState.whatTheyAreDoing != focus {
            lines.append("Actually doing: \(layer.currentState.whatTheyAreDoing)")
        }
        if let tension = layer.openTensions.first, !tension.isEmpty {
            lines.append("Recurring tension: \(tension)")
        }

        if let supplemental = layer.supplementalContext, !supplemental.isEmpty {
            lines.append("")
            lines.append("Additional context:")
            lines.append(supplemental)
        }

        return lines.joined(separator: "\n")
    }
}
