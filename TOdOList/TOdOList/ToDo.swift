// ToDo.swift
// ToDoList - IT8108 Mobile Programming Re-Assessment 2025-2026
// Model layer (MVC)

import Foundation
import UserNotifications

// MARK: - ToDoCategory

/// Represents the category/tag of a to-do item (Stretch Goal 3)
enum ToDoCategory: String, Codable, CaseIterable {
    case personal  = "Personal"
    case work      = "Work"
    case shopping  = "Shopping"
    case health    = "Health"
    case completed = "Completed"

    var iconName: String {
        switch self {
        case .personal:  return "person.fill"
        case .work:      return "briefcase.fill"
        case .shopping:  return "cart.fill"
        case .health:    return "heart.fill"
        case .completed: return "checkmark.seal.fill"
        }
    }
}

// MARK: - ToDo

/// Core model representing a single to-do item
struct ToDo: Equatable, Codable {

    // MARK: Stored Properties
    let id: UUID
    var title: String
    var isComplete: Bool
    var dueDate: Date
    var notes: String?
    var category: ToDoCategory
    var hasReminder: Bool

    // MARK: Initialiser
    init(title: String,
         isComplete: Bool,
         dueDate: Date,
         notes: String?,
         category: ToDoCategory = .personal,
         hasReminder: Bool = false) {
        self.id         = UUID()
        self.title      = title
        self.isComplete = isComplete
        self.dueDate    = dueDate
        self.notes      = notes
        self.category   = category
        self.hasReminder = hasReminder
    }

    // MARK: Equatable
    static func == (lhs: ToDo, rhs: ToDo) -> Bool { lhs.id == rhs.id }
}

// MARK: - Persistence

extension ToDo {

    private static let documentsDirectory =
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!

    static let archiveURL =
        documentsDirectory
            .appendingPathComponent("toDos")
            .appendingPathExtension("plist")

    /// Load saved items from disk. Returns nil when nothing is stored yet.
    static func loadToDos() -> [ToDo]? {
        guard let data = try? Data(contentsOf: archiveURL) else { return nil }
        return try? PropertyListDecoder().decode([ToDo].self, from: data)
    }

    /// Persist the current array to disk.
    static func saveToDos(_ toDos: [ToDo]) {
        let encoded = try? PropertyListEncoder().encode(toDos)
        try? encoded?.write(to: archiveURL, options: .noFileProtection)
    }

    /// Curated sample data shown on first launch.
    static func loadSampleToDos() -> [ToDo] {
        let cal = Calendar.current
        let now = Date()
        return [
            ToDo(title: "Review Swift documentation",
                 isComplete: false,
                 dueDate: cal.date(byAdding: .hour, value: 2,  to: now)!,
                 notes: "Focus on Codable and UITableView sections.",
                 category: .work, hasReminder: true),
            ToDo(title: "Buy groceries for the week",
                 isComplete: false,
                 dueDate: cal.date(byAdding: .day,  value: 1,  to: now)!,
                 notes: "Milk, eggs, bread, vegetables.",
                 category: .shopping, hasReminder: false),
            ToDo(title: "Morning run – 5 km",
                 isComplete: true,
                 dueDate: cal.date(byAdding: .hour, value: -3, to: now)!,
                 notes: "Felt strong throughout.",
                 category: .health, hasReminder: false),
            ToDo(title: "Call Mum on her birthday",
                 isComplete: false,
                 dueDate: cal.date(byAdding: .day,  value: 3,  to: now)!,
                 notes: "Send flowers too.",
                 category: .personal, hasReminder: true),
            ToDo(title: "Submit assignment on Moodle",
                 isComplete: false,
                 dueDate: cal.date(byAdding: .day,  value: -1, to: now)!,
                 notes: "Upload GitHub link. Check rubric first.",
                 category: .work, hasReminder: true),
            ToDo(title: "Drink 8 glasses of water",
                 isComplete: false,
                 dueDate: now,
                 notes: nil,
                 category: .health, hasReminder: false)
        ]
    }
}

// MARK: - Computed Helpers

extension ToDo {

    /// True when the item is past due and not yet complete.
    var isOverdue: Bool { !isComplete && dueDate < Date() }

    /// True when due within the next 24 hours and not yet complete.
    var isDueSoon: Bool {
        guard !isComplete else { return false }
        guard let tomorrow = Calendar.current.date(byAdding: .hour, value: 24, to: Date()) else { return false }
        return dueDate > Date() && dueDate <= tomorrow
    }

    /// Compact date-time string for display in cells.
    var formattedDueDate: String {
        dueDate.formatted(
            .dateTime
                .month(.defaultDigits)
                .day()
                .year(.twoDigits)
                .hour()
                .minute()
        )
    }
}

// MARK: - Notification Helpers (Stretch Goal 5)

extension ToDo {

    /// Schedule a local notification at the item's due date.
    func scheduleNotification() {
        guard hasReminder else { return }

        let content = UNMutableNotificationContent()
        content.title = "⏰ Reminder"
        content.body  = title
        content.sound = .default

        let components = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute], from: dueDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let request = UNNotificationRequest(identifier: id.uuidString,
                                            content: content,
                                            trigger: trigger)
        UNUserNotificationCenter.current().add(request) { error in
            if let e = error { print("Notification error: \(e)") }
        }
    }

    /// Remove any pending notification for this item.
    func removeNotification() {
        UNUserNotificationCenter.current()
            .removePendingNotificationRequests(withIdentifiers: [id.uuidString])
    }
}
