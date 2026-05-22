@preconcurrency import ActivityKit
import SwiftUI
import WidgetKit

struct PraeceptorLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: PraeceptorActivityAttributes.self) { context in
            PraeceptorBannerView(context: context)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    Image(systemName: context.state.phase.systemImage)
                        .font(.system(size: 28, weight: .medium))
                        .foregroundColor(accent)
                        .padding(.leading, 4)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text(context.attributes.sessionLabel)
                        .font(.system(size: 12))
                        .foregroundColor(textMuted)
                        .padding(.trailing, 4)
                }
                DynamicIslandExpandedRegion(.center) {
                    Text("The Praeceptor")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(textPrimary)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text(context.state.phase.expandedDescription)
                        .font(.system(size: 13))
                        .foregroundColor(textPrimary.opacity(0.75))
                        .padding(.bottom, 4)
                }
            } compactLeading: {
                Image(systemName: context.state.phase.systemImage)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(accent)
            } compactTrailing: {
                Text(context.state.phase.compactLabel)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(textPrimary)
            } minimal: {
                Image(systemName: context.state.phase.systemImage)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(accent)
            }
            .widgetURL(URL(string: "praeceptor://session"))
            .keylineTint(accent)
        }
    }

    private let accent      = Color(red: 0.784, green: 0.663, blue: 0.431)
    private let textPrimary = Color(red: 0.937, green: 0.922, blue: 0.890)
    private let textMuted   = Color(red: 0.937, green: 0.922, blue: 0.890).opacity(0.55)
}

// Lock screen / notification banner view
private struct PraeceptorBannerView: View {
    let context: ActivityViewContext<PraeceptorActivityAttributes>

    private let background  = Color(red: 0.051, green: 0.059, blue: 0.078)
    private let accent      = Color(red: 0.784, green: 0.663, blue: 0.431)
    private let textPrimary = Color(red: 0.937, green: 0.922, blue: 0.890)
    private let textMuted   = Color(red: 0.937, green: 0.922, blue: 0.890).opacity(0.55)

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: context.state.phase.systemImage)
                .font(.system(size: 28, weight: .medium))
                .foregroundColor(accent)
                .frame(width: 44)

            VStack(alignment: .leading, spacing: 3) {
                Text("The Praeceptor")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(textPrimary)
                Text(context.state.phase.expandedDescription)
                    .font(.system(size: 13))
                    .foregroundColor(textMuted)
            }

            Spacer()

            Text(context.attributes.sessionLabel)
                .font(.system(size: 11))
                .foregroundColor(textMuted)
        }
        .padding(16)
        .containerBackground(background, for: .widget)
    }
}
