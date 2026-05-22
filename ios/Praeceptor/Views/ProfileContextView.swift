import SwiftUI
import UniformTypeIdentifiers

struct ProfileContextView: View {
    @EnvironmentObject var sessionStore: SessionStore
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var primaryMission = ""
    @State private var sovereigntyStage = ""
    @State private var originalThesis = ""
    @State private var currentFocus = ""
    @State private var lastCommitment = ""
    @State private var openTension = ""
    @State private var supplementalText = ""

    @State private var showFileImporter = false
    @State private var fileError: String? = nil
    @State private var iCloudError: String? = nil

    private var charCount: Int { supplementalText.count }
    private var isOverLimit: Bool { charCount > KnowingLayer.supplementalContextLimit }

    private var canSave: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !isOverLimit
    }

    var body: some View {
        NavigationStack {
            Form {
                profileSection
                contextSection
                if let err = fileError ?? iCloudError {
                    Section {
                        Text(err)
                            .font(.system(size: 13))
                            .foregroundStyle(.red)
                    }
                }
            }
            .navigationTitle("Profile & Context")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save(); dismiss() }
                        .disabled(!canSave)
                }
            }
        }
        .onAppear { populate() }
        .fileImporter(
            isPresented: $showFileImporter,
            allowedContentTypes: [.plainText, .json],
            allowsMultipleSelection: false
        ) { result in
            handleFileImport(result)
        }
    }

    // MARK: — Sections

    private var profileSection: some View {
        Section {
            profileField("Name", binding: $name)
            profileField("What you're building", binding: $primaryMission)
            profileField("Where you stand", binding: $sovereigntyStage)
            profileField("Original thesis", binding: $originalThesis)
            profileField("Current focus", binding: $currentFocus)
            profileField("Last commitment", binding: $lastCommitment)
            profileField("Recurring tension (optional)", binding: $openTension)
        } header: {
            Text("Profile")
        } footer: {
            Text("These answers shape every session. Update as your situation changes.")
        }
    }

    private var contextSection: some View {
        Section {
            ZStack(alignment: .topLeading) {
                if supplementalText.isEmpty {
                    Text("Paste context here — AI chat export, ICP, operating principles, role history...")
                        .foregroundStyle(.secondary)
                        .font(.system(size: 14))
                        .padding(.top, 8)
                        .padding(.leading, 4)
                        .allowsHitTesting(false)
                }
                TextEditor(text: $supplementalText)
                    .font(.system(size: 14))
                    .frame(minHeight: 100)
                    .opacity(supplementalText.isEmpty ? 0.01 : 1)
            }

            HStack {
                Text("\(charCount) / \(KnowingLayer.supplementalContextLimit) characters")
                    .font(.system(size: 12))
                    .foregroundStyle(isOverLimit ? .red : .secondary)
                Spacer()
            }
            .listRowBackground(Color.clear)
            .listRowInsets(.init())
            .padding(.horizontal, 16)

            Button {
                fileError = nil
                showFileImporter = true
            } label: {
                Label("Upload File (.txt or .json)", systemImage: "doc.badge.plus")
            }

            if sessionStore.bridge.contextFolderURL != nil {
                Button {
                    iCloudError = nil
                    syncFromICloud()
                } label: {
                    Label("Sync from iCloud Folder", systemImage: "icloud.and.arrow.down")
                }
            }

            if !supplementalText.isEmpty {
                Button(role: .destructive) {
                    supplementalText = ""
                } label: {
                    Label("Clear Context", systemImage: "trash")
                }
            }
        } header: {
            Text("Supplemental Context")
        } footer: {
            Text("Drop .txt or .json files into iCloud Drive → Praeceptor/ to sync here. Max 2,000 characters (~500 tokens). This context is attached to every session.")
        }
    }

    // MARK: — Helpers

    @ViewBuilder
    private func profileField(_ label: String, binding: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.system(size: 11))
                .foregroundStyle(.secondary)
                .textCase(.uppercase)
            TextField("", text: binding, axis: .vertical)
                .font(.system(size: 15))
                .lineLimit(1...4)
        }
        .padding(.vertical, 4)
    }

    private func populate() {
        guard let layer = sessionStore.knowingLayer else { return }
        name = layer.person.name
        primaryMission = layer.person.primaryMission
        sovereigntyStage = layer.person.sovereigntyStage
        originalThesis = layer.person.originalThesis
        currentFocus = layer.currentState.whatTheyAreDoing
        lastCommitment = layer.currentState.whatTheySaidTheyWouldDo
        openTension = layer.openTensions.first ?? ""
        supplementalText = layer.supplementalContext ?? ""
    }

    private func save() {
        var layer = sessionStore.knowingLayer ?? KnowingLayer.empty
        layer.updated = Date()
        layer.person.name = name.trimmingCharacters(in: .whitespacesAndNewlines)
        layer.person.primaryMission = primaryMission.trimmingCharacters(in: .whitespacesAndNewlines)
        layer.person.sovereigntyStage = sovereigntyStage.trimmingCharacters(in: .whitespacesAndNewlines)
        layer.person.originalThesis = originalThesis.trimmingCharacters(in: .whitespacesAndNewlines)
        layer.currentState.whatTheyAreDoing = currentFocus.trimmingCharacters(in: .whitespacesAndNewlines)
        layer.currentState.whatTheySaidTheyWouldDo = lastCommitment.trimmingCharacters(in: .whitespacesAndNewlines)
        let tension = openTension.trimmingCharacters(in: .whitespacesAndNewlines)
        layer.openTensions = tension.isEmpty ? [] : [tension]
        let trimmedSupplemental = supplementalText.trimmingCharacters(in: .whitespacesAndNewlines)
        layer.supplementalContext = trimmedSupplemental.isEmpty ? nil : String(trimmedSupplemental.prefix(KnowingLayer.supplementalContextLimit))
        sessionStore.updateProfile(layer)
    }

    private func handleFileImport(_ result: Result<[URL], Error>) {
        fileError = nil
        switch result {
        case .success(let urls):
            guard let url = urls.first else { return }
            guard url.startAccessingSecurityScopedResource() else {
                fileError = "Could not access the selected file."
                return
            }
            defer { url.stopAccessingSecurityScopedResource() }
            do {
                let content = try String(contentsOf: url, encoding: .utf8)
                let trimmed = content.trimmingCharacters(in: .whitespacesAndNewlines)
                supplementalText = String(trimmed.prefix(KnowingLayer.supplementalContextLimit))
            } catch {
                fileError = "Could not read file: \(error.localizedDescription)"
            }
        case .failure(let error):
            fileError = "Import failed: \(error.localizedDescription)"
        }
    }

    private func syncFromICloud() {
        guard let text = sessionStore.bridge.scanICloudContextFolder() else {
            iCloudError = "No .txt or .json files found in iCloud Drive → Praeceptor/"
            return
        }
        supplementalText = String(text.prefix(KnowingLayer.supplementalContextLimit))
    }
}
