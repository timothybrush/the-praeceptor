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
    @State private var copied = false

    private var theme: TimeOfDayTheme { TimeOfDayTheme.current(TimeOfDay.current) }
    private var charCount: Int { supplementalText.count }
    private var isOverLimit: Bool { charCount > KnowingLayer.supplementalContextLimit }
    private var canSave: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !isOverLimit
    }

    var body: some View {
        ZStack {
            theme.background.ignoresSafeArea()
            VStack(spacing: 0) {
                sheetHeader
                theme.line.frame(height: 1)
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        profileSection
                        sectionDivider
                        supplementalSection
                        sectionDivider
                        copyContextSection
                    }
                    .padding(.bottom, 60)
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

    // MARK: — Header

    private var sheetHeader: some View {
        HStack {
            Button("Cancel") { dismiss() }
                .font(TimeOfDayTheme.body(15))
                .foregroundColor(theme.textSecondary)
                .frame(minWidth: 64, alignment: .leading)

            Spacer()

            Text("Profile & Context")
                .font(TimeOfDayTheme.body(15))
                .fontWeight(.medium)
                .foregroundColor(theme.text)

            Spacer()

            Button("Save") { save(); dismiss() }
                .font(TimeOfDayTheme.body(15))
                .fontWeight(.medium)
                .foregroundColor(canSave ? theme.accent : theme.textGhost)
                .frame(minWidth: 64, alignment: .trailing)
                .disabled(!canSave)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
    }

    // MARK: — Profile Section

    private var profileSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("PROFILE")
                .font(TimeOfDayTheme.mono(10))
                .foregroundColor(theme.accent)
                .kerning(2.4)
                .textCase(.uppercase)

            VStack(spacing: 0) {
                profileRow(label: "Name", binding: $name, placeholder: "Your name")
                theme.line.frame(height: 1)
                profileRow(label: "What you're building", binding: $primaryMission, placeholder: "One line")
                theme.line.frame(height: 1)
                profileRow(label: "Where you stand", binding: $sovereigntyStage, placeholder: "Your current stage")
                theme.line.frame(height: 1)
                profileRow(label: "Original thesis", binding: $originalThesis, placeholder: "Why you started")
                theme.line.frame(height: 1)
                profileRow(label: "Current focus", binding: $currentFocus, placeholder: "What you're working on now")
                theme.line.frame(height: 1)
                profileRow(label: "Last commitment", binding: $lastCommitment, placeholder: "What you said you'd do")
                theme.line.frame(height: 1)
                profileRow(label: "Recurring tension", binding: $openTension, placeholder: "Optional")
            }
            .background(theme.raised)
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .stroke(theme.line, lineWidth: 1)
            )

            Text("These answers shape every session. Update as your situation changes.")
                .font(TimeOfDayTheme.body(13))
                .foregroundColor(theme.textTertiary)
                .lineSpacing(3)
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 24)
    }

    private func profileRow(label: String, binding: Binding<String>, placeholder: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(TimeOfDayTheme.mono(9))
                .foregroundColor(theme.textTertiary)
                .kerning(1.8)
                .textCase(.uppercase)
            TextField(placeholder, text: binding, axis: .vertical)
                .font(TimeOfDayTheme.body(15))
                .foregroundColor(theme.text)
                .tint(theme.accent)
                .lineLimit(1...4)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }

    // MARK: — Supplemental Section

    private var supplementalSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("SUPPLEMENTAL CONTEXT")
                .font(TimeOfDayTheme.mono(10))
                .foregroundColor(theme.accent)
                .kerning(2.4)
                .textCase(.uppercase)

            ZStack(alignment: .topLeading) {
                if supplementalText.isEmpty {
                    Text("Paste context here — AI chat export, ICP, operating principles, role history…")
                        .font(TimeOfDayTheme.body(14))
                        .foregroundColor(theme.textGhost)
                        .padding(.top, 14)
                        .padding(.leading, 17)
                        .allowsHitTesting(false)
                }
                TextEditor(text: $supplementalText)
                    .font(TimeOfDayTheme.body(14))
                    .foregroundColor(theme.text)
                    .tint(theme.accent)
                    .scrollContentBackground(.hidden)
                    .background(.clear)
                    .frame(minHeight: 120)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
            }
            .background(theme.raised)
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .stroke(isOverLimit ? Color.red.opacity(0.6) : theme.line, lineWidth: 1)
            )

            HStack {
                Text("\(charCount) / \(KnowingLayer.supplementalContextLimit) characters")
                    .font(TimeOfDayTheme.mono(10))
                    .foregroundColor(isOverLimit ? .red : theme.textGhost)
                    .kerning(1.4)
                Spacer()
            }

            uploadButton
            iCloudButton
            if !supplementalText.isEmpty { clearButton }

            if let err = fileError ?? iCloudError {
                Text(err)
                    .font(TimeOfDayTheme.body(13))
                    .foregroundColor(.red)
                    .lineSpacing(3)
            }

            Text("Max \(KnowingLayer.supplementalContextLimit) characters (~500 tokens). Attached to every session.")
                .font(TimeOfDayTheme.body(13))
                .foregroundColor(theme.textTertiary)
                .lineSpacing(3)
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 24)
    }

    private var uploadButton: some View {
        Button { fileError = nil; showFileImporter = true } label: {
            HStack(spacing: 12) {
                Image(systemName: "arrow.up.doc")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(theme.accent)
                    .frame(width: 20)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Upload File")
                        .font(TimeOfDayTheme.body(15))
                        .foregroundColor(theme.text)
                    Text(".txt or .json")
                        .font(TimeOfDayTheme.mono(10))
                        .foregroundColor(theme.textTertiary)
                        .kerning(1.4)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 12))
                    .foregroundColor(theme.textGhost)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(theme.raised)
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 10, style: .continuous).stroke(theme.line, lineWidth: 1))
        }
    }

    private var iCloudButton: some View {
        let usingICloud = sessionStore.bridge.isUsingICloud
        let subtitle = usingICloud
            ? "iCloud Drive → Praeceptor/"
            : "Files app → On My iPhone → Praeceptor"
        return Button { iCloudError = nil; syncFromICloud() } label: {
            HStack(spacing: 12) {
                Image(systemName: usingICloud ? "icloud.and.arrow.down" : "folder")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(theme.accent)
                    .frame(width: 20)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Sync from Context Folder")
                        .font(TimeOfDayTheme.body(15))
                        .foregroundColor(theme.text)
                    Text(subtitle)
                        .font(TimeOfDayTheme.mono(10))
                        .foregroundColor(theme.textTertiary)
                        .kerning(1.4)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 12))
                    .foregroundColor(theme.textGhost)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(theme.raised)
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 10, style: .continuous).stroke(theme.line, lineWidth: 1))
        }
    }

    private var clearButton: some View {
        Button { supplementalText = "" } label: {
            HStack(spacing: 12) {
                Image(systemName: "trash")
                    .font(.system(size: 14))
                    .foregroundColor(theme.bad)
                    .frame(width: 20)
                Text("Clear Context")
                    .font(TimeOfDayTheme.body(15))
                    .foregroundColor(theme.bad)
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(theme.raised)
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 10, style: .continuous).stroke(theme.line, lineWidth: 1))
        }
    }

    // MARK: — Copy Context

    private var copyContextSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("CLAUDE CODE BRIEF")
                .font(TimeOfDayTheme.mono(10))
                .foregroundColor(theme.accent)
                .kerning(2.4)
                .textCase(.uppercase)

            Button {
                UIPasteboard.general.string = KnowingLayerBridge.claudeCodeContextPrompt
                copied = true
                Task {
                    try? await Task.sleep(for: .seconds(2))
                    copied = false
                }
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: copied ? "checkmark" : "doc.on.doc")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(theme.accent)
                        .frame(width: 20)
                    Text(copied ? "Copied" : "Copy Prompt")
                        .font(TimeOfDayTheme.body(15))
                        .foregroundColor(theme.text)
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .background(theme.raised)
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                .overlay(RoundedRectangle(cornerRadius: 10, style: .continuous).stroke(copied ? theme.accent.opacity(0.4) : theme.line, lineWidth: 1))
            }
            .animation(.easeInOut(duration: 0.2), value: copied)

            Text("Paste into Claude Code on your machine. It will generate a context brief from your actual work — git history, tasks, codebase. Paste the result into Supplemental Context above.")
                .font(TimeOfDayTheme.body(13))
                .foregroundColor(theme.textTertiary)
                .lineSpacing(3)
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 24)
    }

    // MARK: — Helpers

    private var sectionDivider: some View {
        theme.line.frame(height: 1).padding(.horizontal, 24)
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
        let trimmed = supplementalText.trimmingCharacters(in: .whitespacesAndNewlines)
        layer.supplementalContext = trimmed.isEmpty ? nil : String(trimmed.prefix(KnowingLayer.supplementalContextLimit))
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
                supplementalText = String(content.trimmingCharacters(in: .whitespacesAndNewlines).prefix(KnowingLayer.supplementalContextLimit))
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
