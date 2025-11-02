//
//  NotificationManager.swift
//  AI Tasker
//
//  Created by Mark Dias on 01/11/2025.
//

import UserNotifications
import CoreData

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
        let taskId = task.objectID.uriRepresentation().lastPathComponent
        guard let scheduledTime = task.scheduledTime else { return }

        let content = UNMutableNotificationContent()
        content.title = "Task Reminder"
        content.body = task.title
        content.sound = .default
        content.badge = 1

        // Add custom data
        content.userInfo = [
            "taskId": taskId,
            "taskTitle": task.title
        ]

        // Calculate time interval
        let timeInterval = max(scheduledTime.timeIntervalSinceNow, 60) // Minimum 1 minute

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: false)
        let request = UNNotificationRequest(identifier: taskId, content: content, trigger: trigger)

        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error.localizedDescription)")
            } else {
                print("Notification scheduled for task: \(task.title)")
            }
        }

        notificationCenter.setBadgeCount(1, withCompletionHandler: nil)
    }

    // MARK: - Cancel Task Reminder
    func cancelTaskReminder(taskId: String) {
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [taskId])
        notificationCenter.setBadgeCount(0, withCompletionHandler: nil)
    }

    // MARK: - Cancel All Reminders
    func cancelAllReminders() {
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.removeAllPendingNotificationRequests()
        notificationCenter.setBadgeCount(0, withCompletionHandler: nil)
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
