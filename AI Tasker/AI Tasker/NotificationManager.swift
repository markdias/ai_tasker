//
//  NotificationManager.swift
//  AI Tasker
//
//  Created by Mark Dias on 01/11/2025.
//

import UserNotifications

class NotificationManager {
    static let shared = NotificationManager()

    private init() {}

    // MARK: - Request Permission
    func requestNotificationPermission(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Error requesting notification permission: \(error.localizedDescription)")
                    completion(false)
                } else {
                    completion(granted)
                }
            }
        }
    }

    // MARK: - Schedule Task Reminder
    func scheduleTaskReminder(task: Task) {
        guard let taskId = task.objectID.uriRepresentation().lastPathComponent else { return }
        guard let scheduledTime = task.scheduledTime else { return }

        let content = UNMutableNotificationContent()
        content.title = "Task Reminder"
        content.body = task.title ?? "Unnamed Task"
        content.sound = .default
        content.badge = NSNumber(value: UIApplication.shared.applicationIconBadgeNumber + 1)

        // Add custom data
        content.userInfo = [
            "taskId": taskId,
            "taskTitle": task.title ?? "Task"
        ]

        // Calculate time interval
        let timeInterval = max(scheduledTime.timeIntervalSinceNow, 60) // Minimum 1 minute

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: false)
        let request = UNNotificationRequest(identifier: taskId, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error.localizedDescription)")
            } else {
                print("Notification scheduled for task: \(task.title ?? "Unknown")")
            }
        }
    }

    // MARK: - Cancel Task Reminder
    func cancelTaskReminder(taskId: String) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [taskId])
    }

    // MARK: - Cancel All Reminders
    func cancelAllReminders() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }

    // MARK: - Schedule Multiple Reminders
    func scheduleRemindersForTasks(_ tasks: [Task]) {
        for task in tasks {
            if task.scheduledTime != nil {
                scheduleTaskReminder(task: task)
            }
        }
    }

    // MARK: - Get Pending Notifications
    func getPendingNotifications(completion: @escaping ([UNNotificationRequest]) -> Void) {
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            completion(requests)
        }
    }

    // MARK: - Check Notification Status
    func getNotificationSettings(completion: @escaping (UNNotificationSettings) -> Void) {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            completion(settings)
        }
    }
}
