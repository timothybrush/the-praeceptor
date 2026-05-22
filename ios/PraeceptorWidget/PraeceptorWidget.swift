import WidgetKit
import SwiftUI

struct PraeceptorEntry: TimelineEntry {
    let date: Date
    let sessionLabel: String
    let quote: String

    static let characterQuotes: [String] = [
        "The gap between what you said\nyou'd do and what you did.\n— The Praeceptor",
        "Begin before the noise does.\n— Seneca",
        "Reality is neutral.\nYour story about it isn't.\n— Naval",
        "The standard is the standard.\n— Walsh",
        "Every day you waste\nis one you can't make up.\n— Munger",
        "What are you avoiding\nby focusing on this?\n— The Praeceptor",
        "Who benefits\nif this stays unclear?\n— The Praeceptor",
        "Most people plan the day.\nThe rest have already started.\n— Grove",
        "You're either closing the distance\nor you're drifting.\n— Midday.",
        "What would you tell someone else\nin your exact position?\n— The Praeceptor",
    ]
}

struct PraeceptorTimelineProvider: TimelineProvider {
    func placeholder(in context: Context) -> PraeceptorEntry {
        PraeceptorEntry(date: Date(), sessionLabel: "Evening session", quote: PraeceptorEntry.characterQuotes[0])
    }

    func getSnapshot(in context: Context, completion: @escaping (PraeceptorEntry) -> Void) {
        completion(PraeceptorEntry(date: Date(), sessionLabel: currentSessionLabel(), quote: quoteOfTheDay()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<PraeceptorEntry>) -> Void) {
        let entry = PraeceptorEntry(date: Date(), sessionLabel: currentSessionLabel(), quote: quoteOfTheDay())
        let nextHour = Calendar.current.date(byAdding: .hour, value: 1, to: Date()) ?? Date()
        completion(Timeline(entries: [entry], policy: .after(nextHour)))
    }

    private func quoteOfTheDay() -> String {
        let day = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 1
        return PraeceptorEntry.characterQuotes[day % PraeceptorEntry.characterQuotes.count]
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
                Text(entry.quote)
                    .font(.system(size: 11))
                    .foregroundColor(textPrimary.opacity(0.75))
                    .lineLimit(3)
                    .fixedSize(horizontal: false, vertical: true)
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
