//
//  AppSettings.swift
//  AI Tasker
//
//  Created by Mark Dias on 01/11/2025.
//

import Foundation
import Combine

@MainActor
final class AppSettings: ObservableObject {
    static let shared = AppSettings()

    private let keychainManager = KeychainManager.shared
    private let userDefaults = UserDefaults.standard

    private let modelKey = "selectedModel"
    private let taskStyleKey = "taskStyle"

    @Published var selectedModel: String {
        didSet {
            userDefaults.set(selectedModel, forKey: modelKey)
            OpenAIManager.shared.setSelectedModel(selectedModel)
        }
    }

    @Published var taskStyle: String {
        didSet {
            userDefaults.set(taskStyle, forKey: taskStyleKey)
            OpenAIManager.shared.setTaskStyle(taskStyle)
        }
    }

    @Published var hasAPIKey: Bool = false

    init() {
        selectedModel = userDefaults.string(forKey: modelKey) ?? "gpt-4-turbo"
        taskStyle = userDefaults.string(forKey: taskStyleKey) ?? "detailed"
        hasAPIKey = keychainManager.hasAPIKey()
    }

    // MARK: - API Key Management
    func saveAPIKey(_ apiKey: String) throws {
        try keychainManager.saveAPIKey(apiKey)
        hasAPIKey = true
    }

    func getAPIKey() throws -> String? {
        return try keychainManager.getAPIKey()
    }

    func deleteAPIKey() throws {
        try keychainManager.deleteAPIKey()
        hasAPIKey = false
    }
}
