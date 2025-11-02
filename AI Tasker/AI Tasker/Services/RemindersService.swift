import Foundation
import EventKit

/// Service for syncing tasks to Apple Reminders
class RemindersService: NSObject {
    static let shared = RemindersService()

    private let eventStore = EKEventStore()
    private var reminderCalendar: EKCalendar?

    // MARK: - Request Permissions

    func requestRemindersAccess(completion: @escaping (Bool, Error?) -> Void) {
        if #available(iOS 17.0, *) {
            eventStore.requestFullAccessToReminders { granted, error in
                DispatchQueue.main.async {
                    if granted {
                        self.setupReminderCalendar()
                    }
                    completion(granted, error)
                }
            }
        } else {
            eventStore.requestAccess(to: .reminder) { granted, error in
                DispatchQueue.main.async {
                    if granted {
                        self.setupReminderCalendar()
                    }
                    completion(granted, error)
                }
            }
        }
    }

    func setupReminderCalendar() {
        let calendars = eventStore.calendars(for: .reminder)

        // Try to find existing Promptodo calendar
        if let existingCalendar = calendars.first(where: { $0.title == "Promptodo" }) {
            reminderCalendar = existingCalendar
            return
        }

        // Create new Promptodo calendar if it doesn't exist
        let newCalendar = EKCalendar(for: .reminder, eventStore: eventStore)
        newCalendar.title = "Promptodo"
        newCalendar.source = eventStore.defaultCalendarForNewReminders()?.source ?? eventStore.sources.first

        do {
            try eventStore.saveCalendar(newCalendar, commit: true)
            reminderCalendar = newCalendar
        } catch {
            print("Failed to create Promptodo calendar: \(error.localizedDescription)")
            // Fallback to default calendar
            reminderCalendar = eventStore.defaultCalendarForNewReminders()
        }
    }

    // MARK: - Create Reminder

    func createReminder(for task: TaskLocal, completion: @escaping (String?, Error?) -> Void) {
        guard let calendar = reminderCalendar ?? eventStore.defaultCalendarForNewReminders() else {
            completion(nil, NSError(domain: "RemindersService", code: 1, userInfo: [NSLocalizedDescriptionKey: "No calendar available"]))
            return
        }

        let reminder = EKReminder(eventStore: eventStore)
        reminder.title = task.title
        reminder.calendar = calendar
        reminder.notes = task.taskDescription ?? ""

        // Set due date if available
        if let dueDate = task.dueDate {
            let dueDateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: dueDate)
            reminder.dueDateComponents = dueDateComponents
        }

        // Add unique identifier for tracking
        reminder.notes = (reminder.notes ?? "") + "\n[Promptodo ID: \(task.id)]"

        do {
            try eventStore.save(reminder, commit: true)
            completion(reminder.calendarItemIdentifier, nil)
        } catch {
            completion(nil, error)
        }
    }

    // MARK: - Update Reminder

    func updateReminder(taskId: String, reminderId: String, task: TaskLocal, completion: @escaping (Error?) -> Void) {
        guard let reminder = eventStore.calendarItem(withIdentifier: reminderId) as? EKReminder else {
            completion(NSError(domain: "RemindersService", code: 2, userInfo: [NSLocalizedDescriptionKey: "Reminder not found"]))
            return
        }

        reminder.title = task.title
        reminder.notes = (task.taskDescription ?? "") + "\n[Promptodo ID: \(task.id)]"

        if let dueDate = task.dueDate {
            let dueDateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: dueDate)
            reminder.dueDateComponents = dueDateComponents
        }

        do {
            try eventStore.save(reminder, commit: true)
            completion(nil)
        } catch {
            completion(error)
        }
    }

    // MARK: - Delete Reminder

    func deleteReminder(reminderId: String, completion: @escaping (Error?) -> Void) {
        guard let reminder = eventStore.calendarItem(withIdentifier: reminderId) as? EKReminder else {
            completion(NSError(domain: "RemindersService", code: 3, userInfo: [NSLocalizedDescriptionKey: "Reminder not found"]))
            return
        }

        do {
            try eventStore.remove(reminder, commit: true)
            completion(nil)
        } catch {
            completion(error)
        }
    }

    // MARK: - Batch Sync

    /// Sync all tasks in a project to Reminders
    func syncProjectToReminders(project: ProjectLocal, completion: @escaping ([String: String], [Error]) -> Void) {
        var reminderIds: [String: String] = [:]
        var errors: [Error] = []

        let group = DispatchGroup()
        let queue = DispatchQueue(label: "com.promptodo.reminders.sync")

        for task in project.tasks {
            group.enter()
            queue.async {
                self.createReminder(for: task) { reminderId, error in
                    if let error = error {
                        errors.append(error)
                    } else if let reminderId = reminderId {
                        reminderIds[task.id] = reminderId
                    }
                    group.leave()
                }
            }
        }

        group.notify(queue: .main) {
            completion(reminderIds, errors)
        }
    }

    // MARK: - Check Authorization Status

    func checkAuthorizationStatus() -> EKAuthorizationStatus {
        if #available(iOS 17.0, *) {
            return EKEventStore.authorizationStatus(for: .reminder)
        } else {
            return EKEventStore.authorizationStatus(for: .reminder)
        }
    }
}
