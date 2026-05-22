import WidgetKit
import SwiftUI

struct PraeceptorEntry: TimelineEntry {
    let date: Date
    let sessionLabel: String
}

struct PraeceptorTimelineProvider: TimelineProvider {
    func placeholder(in context: Context) -> PraeceptorEntry {
        PraeceptorEntry(date: Date(), sessionLabel: "Evening session")
    }

    func getSnapshot(in context: Context, completion: @escaping (PraeceptorEntry) -> Void) {
        completion(PraeceptorEntry(date: Date(), sessionLabel: currentSessionLabel()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<PraeceptorEntry>) -> Void) {
        let entry = PraeceptorEntry(date: Date(), sessionLabel: currentSessionLabel())
        let nextHour = Calendar.current.date(byAdding: .hour, value: 1, to: Date()) ?? Date()
        completion(Timeline(entries: [entry], policy: .after(nextHour)))
    }

    private func currentSessionLabel() -> String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12: return "Morning session"
        case 12..<17: return "Midday session"
        default: return "Evening session"
        }
    }
}

struct PraeceptorWidgetView: View {
    let entry: PraeceptorEntry
    @Environment(\.widgetFamily) var family

    private let widgetBackground = Color(red: 0.051, green: 0.059, blue: 0.078)
    private let accent = Color(red: 0.784, green: 0.663, blue: 0.431)
    private let textPrimary = Color(red: 0.937, green: 0.922, blue: 0.890)
    private let textMuted = Color(red: 0.937, green: 0.922, blue: 0.890).opacity(0.5)

    var body: some View {
        content
            .containerBackground(widgetBackground, for: .widget)
            .widgetURL(URL(string: "praeceptor://session"))
    }

    @ViewBuilder
    private var content: some View {
        switch family {
        case .systemMedium:
            mediumView
        default:
            smallView
        }
    }

    private var smallView: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("The Praeceptor")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(textPrimary)
            Text(entry.sessionLabel)
                .font(.system(size: 11))
                .foregroundColor(textMuted)
                .padding(.top, 2)
            Spacer()
            Image(systemName: "mic.fill")
                .font(.system(size: 30, weight: .medium))
                .foregroundColor(accent)
            Spacer()
            Text("Tap to speak")
                .font(.system(size: 11))
                .foregroundColor(textMuted)
        }
        .padding(14)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
    }

    private var mediumView: some View {
        HStack(spacing: 20) {
            VStack(spacing: 8) {
                Image(systemName: "mic.fill")
                    .font(.system(size: 32, weight: .medium))
                    .foregroundColor(accent)
                Text("Tap to speak")
                    .font(.system(size: 10))
                    .foregroundColor(textMuted)
            }
            .frame(width: 80)

            VStack(alignment: .leading, spacing: 4) {
                Text("The Praeceptor")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(textPrimary)
                Text(entry.sessionLabel)
                    .font(.system(size: 12))
                    .foregroundColor(textMuted)
                Spacer()
                Text("Hold to speak.\nThe Praeceptor is ready.")
                    .font(.system(size: 12))
                    .foregroundColor(textPrimary.opacity(0.7))
                    .lineLimit(2)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(16)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct PraeceptorWidget: Widget {
    let kind = "PraeceptorWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: PraeceptorTimelineProvider()) { entry in
            PraeceptorWidgetView(entry: entry)
        }
        .configurationDisplayName("The Praeceptor")
        .description("One tap to start a session.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
