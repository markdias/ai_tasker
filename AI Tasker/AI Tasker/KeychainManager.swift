//
//  KeychainManager.swift
//  AI Tasker
//
//  Created by Mark Dias on 01/11/2025.
//

import Foundation
import Security

class KeychainManager {
    static let shared = KeychainManager()

    private let serviceIdentifier = "com.markdias.aitasker"

    // MARK: - Save API Key
    func saveAPIKey(_ apiKey: String) {
        let data = apiKey.data(using: .utf8)!

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceIdentifier,
            kSecAttrAccount as String: "openai_api_key",
            kSecValueData as String: data
        ]

        // Try to delete existing key first
        SecItemDelete(query as CFDictionary)

        // Add new key
        let status = SecItemAdd(query as CFDictionary, nil)

        if status != errSecSuccess {
            print("Failed to save API key to Keychain: \(status)")
        }
    }

    // MARK: - Retrieve API Key
    func retrieveAPIKey() -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceIdentifier,
            kSecAttrAccount as String: "openai_api_key",
            kSecReturnData as String: true
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        if status == errSecItemNotFound {
            return nil
        }

        if status != errSecSuccess {
            print("Failed to retrieve API key from Keychain: \(status)")
            return nil
        }

        guard let data = result as? Data,
              let apiKey = String(data: data, encoding: .utf8) else {
            print("Failed to decode API key from Keychain")
            return nil
        }

        return apiKey
    }

    // MARK: - Delete API Key
    func deleteAPIKey() {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceIdentifier,
            kSecAttrAccount as String: "openai_api_key"
        ]

        let status = SecItemDelete(query as CFDictionary)

        if status != errSecSuccess && status != errSecItemNotFound {
            print("Failed to delete API key from Keychain: \(status)")
        }
    }

    // MARK: - Check if API Key exists
    func hasAPIKey() -> Bool {
        return retrieveAPIKey() != nil
    }
}

enum KeychainError: LocalizedError {
    case saveFailed(status: OSStatus)
    case retrieveFailed(status: OSStatus)
    case decodeFailed
    case deleteFailed(status: OSStatus)

    var errorDescription: String? {
        switch self {
        case .saveFailed(let status):
            return "Failed to save API key. Status: \(status)"
        case .retrieveFailed(let status):
            return "Failed to retrieve API key. Status: \(status)"
        case .decodeFailed:
            return "Failed to decode API key from keychain"
        case .deleteFailed(let status):
            return "Failed to delete API key. Status: \(status)"
        }
    }
}
