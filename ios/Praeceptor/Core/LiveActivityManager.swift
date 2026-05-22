@preconcurrency import ActivityKit
import Foundation

@MainActor
final class LiveActivityManager {
    private var activity: Activity<PraeceptorActivityAttributes>?

    func startActivity(sessionLabel: String) {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else { return }
        let attributes = PraeceptorActivityAttributes(sessionLabel: sessionLabel)
        let state = PraeceptorActivityAttributes.ContentState(phase: .recording)
        activity = try? Activity.request(
            attributes: attributes,
            content: .init(state: state, staleDate: nil),
            pushType: nil
        )
    }

    func updateActivity(phase: ActivityPhase) {
        Task { @MainActor [weak self] in
            await self?.activity?.update(.init(state: .init(phase: phase), staleDate: nil))
        }
    }

    func endActivity() {
        Task { @MainActor [weak self] in
            await self?.activity?.end(
                .init(state: .init(phase: .speaking), staleDate: nil),
                dismissalPolicy: .immediate
            )
            self?.activity = nil
        }
    }
}
