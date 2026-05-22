import Foundation
import UserNotifications

enum SessionReminder: String, CaseIterable {
    case morning = "com.praeceptor.reminder.morning"
    case midday  = "com.praeceptor.reminder.midday"
    case evening = "com.praeceptor.reminder.evening"

    var label: String {
        switch self {
        case .morning: return "Morning"
        case .midday:  return "Midday"
        case .evening: return "Evening"
        }
    }

    var subtitle: String {
        switch self {
        case .morning: return "8:00 AM"
        case .midday:  return "12:00 PM"
        case .evening: return "6:00 PM"
        }
    }

    var hour: Int {
        switch self {
        case .morning: return 8
        case .midday:  return 12
        case .evening: return 18
        }
    }

    var messages: [String] {
        switch self {
        case .morning:
            return [
                "Begin before the noise does.\n— Seneca",
                "Most people plan the day. The rest have already started.\n— Grove",
                "What are you building today?\n— Morning session.",
                "The first hour sets the trajectory. It's starting now.\n— The Praeceptor"
            ]
        case .midday:
            return [
                "What happened to what you said this morning?\n— Check in.",
                "You're either closing the distance or you're drifting.\n— Midday.",
                "Half the day is gone. The gap between intent and action is measured in afternoons like this.\n— The Praeceptor",
                "The work is either moving or it isn't. Come find out.\n— Naval"
            ]
        case .evening:
            return [
                "Before you close the day — a few minutes.\n— Aurelius",
                "The session is open.\n— Evening.",
                "What happened today that you haven't sat with yet?\n— The Praeceptor",
                "The day isn't closed yet.\n— Come in."
            ]
        }
    }
}

@MainActor
final class NotificationManager: ObservableObject {
    @Published private(set) var enabledReminders: Set<SessionReminder> = []

    init() {
        Task { await refreshStatus() }
    }

    func isEnabled(_ reminder: SessionReminder) -> Bool {
        enabledReminders.contains(reminder)
    }

    func toggle(_ reminder: SessionReminder) async {
        if enabledReminders.contains(reminder) {
            cancel(reminder)
        } else {
            let center = UNUserNotificationCenter.current()
            let granted = (try? await center.requestAuthorization(options: [.alert, .sound])) ?? false
            guard granted else {
                await refreshStatus()
                return
            }
            schedule(reminder)
        }
        await refreshStatus()
    }

    private func schedule(_ reminder: SessionReminder) {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [reminder.rawValue])

        let content = UNMutableNotificationContent()
        content.title = UserDefaults.standard.string(forKey: "mentor_name") ?? "The Praeceptor"
        content.body = reminder.messages.randomElement() ?? reminder.messages[0]
        content.sound = .default

        var components = DateComponents()
        components.hour = reminder.hour
        components.minute = 0

        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let request = UNNotificationRequest(identifier: reminder.rawValue, content: content, trigger: trigger)
        center.add(request)
    }

    private func cancel(_ reminder: SessionReminder) {
        UNUserNotificationCenter.current()
            .removePendingNotificationRequests(withIdentifiers: [reminder.rawValue])
        enabledReminders.remove(reminder)
    }

    private func refreshStatus() async {
        let pending = await UNUserNotificationCenter.current().pendingNotificationRequests()
        let pendingIDs = Set(pending.map(\.identifier))
        enabledReminders = Set(SessionReminder.allCases.filter { pendingIDs.contains($0.rawValue) })
    }
}
