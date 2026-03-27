//
        //
    //  Project: Keychain_SwiftUI
    //  File: KeychainHelper.swift
    //  Created by Noah Carpenter 
    //
    //  📺 YouTube: Noah Does Coding
    //  https://www.youtube.com/@NoahDoesCoding97
    //  Like and Subscribe for coding tutorials and fun! 💻✨
    //  Dream Big. Code Bigger 🚀
    //

    


//
//  KeychainHelper.swift
//  KeychainDemo
//  Modern wrapper around iOS Keychain Services API
//  Hides C-style CFDictionary interface behind clean Swift methods
//  Includes biometric authentication support
//

import Foundation
import Security           // Keychain Services API
import LocalAuthentication // FaceID / TouchID / passcode

/// Thread-safe Keychain wrapper with biometric support
/// Sendable conformance satisfies Swift 6 strict concurrency
final class KeychainHelper: Sendable {

    // MARK: - Properties

    // Shared singleton — one instance for the entire app
    static let shared = KeychainHelper()

    // Service identifier — scopes Keychain items to this app
    // Using bundle ID ensures items don't collide with other apps
    private let service: String

    // MARK: - Init

    init(service: String = Bundle.main.bundleIdentifier ?? "com.app.default") {
        self.service = service
    }

    // MARK: - Save

    /// Save data to the Keychain for a given key
    /// Uses update-first strategy to avoid errSecDuplicateItem errors
    /// - Parameters:
    ///   - data: The raw Data to store (encrypted at rest)
    ///   - key: A unique identifier for this item (e.g., "authToken")
    func save(_ data: Data, for key: String) {

        // Query to identify the existing item
        let query: [String: Any] = [
            kSecClass as String:       kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key
        ]

        // The new value to store
        let attributes: [String: Any] = [
            kSecValueData as String: data
        ]

        // Try update first — this is the common path after initial save
        let updateStatus = SecItemUpdate(query as CFDictionary, attributes as CFDictionary)

        if updateStatus == errSecItemNotFound {
            // Item doesn't exist yet — add as new entry
            var newItem = query
            newItem[kSecValueData as String] = data
            let addStatus = SecItemAdd(newItem as CFDictionary, nil)

            if addStatus != errSecSuccess {
                print("Keychain save error: \(addStatus)")
            }
        } else if updateStatus != errSecSuccess {
            print("Keychain update error: \(updateStatus)")
        }
    }

    // MARK: - Read

    /// Read data from the Keychain for a given key
    /// - Parameter key: The unique identifier for the item
    /// - Returns: The stored Data, or nil if not found
    func read(for key: String) -> Data? {

        let query: [String: Any] = [
            kSecClass as String:       kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecReturnData as String:  true,             // Return the stored bytes
            kSecMatchLimit as String:  kSecMatchLimitOne  // One result only
        ]

        // SecItemCopyMatching writes the result into this reference
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        guard status == errSecSuccess else { return nil }
        return result as? Data
    }

    // MARK: - Delete

    /// Delete an item from the Keychain
    /// - Parameter key: The unique identifier for the item to remove
    func delete(for key: String) {

        let query: [String: Any] = [
            kSecClass as String:       kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key
        ]

        // errSecItemNotFound is not an error — the item is already gone
        let status = SecItemDelete(query as CFDictionary)

        if status != errSecSuccess && status != errSecItemNotFound {
            print("Keychain delete error: \(status)")
        }
    }

    // MARK: - Convenience (String)

    /// Save a String value (converted to UTF-8 Data)
    func save(_ value: String, for key: String) {
        guard let data = value.data(using: .utf8) else { return }
        save(data, for: key)
    }

    /// Read a String value from the Keychain
    func readString(for key: String) -> String? {
        guard let data = read(for: key) else { return nil }
        return String(data: data, encoding: .utf8)
    }

    // MARK: - Biometric Authentication

    /// Authenticates the user with FaceID, TouchID, or device passcode
    /// Requires NSFaceIDUsageDescription in Info.plist for FaceID
    /// - Parameters:
    ///   - reason: Message shown in the biometric prompt
    ///   - completion: Called on main thread with authentication result
    func authenticateWithBiometrics(
        reason: String = "Authenticate to access secure data",
        completion: @escaping (Bool) -> Void
    ) {
        let context = LAContext()
        var error: NSError?

        // .deviceOwnerAuthentication includes passcode fallback
        // .deviceOwnerAuthenticationWithBiometrics is biometrics-only
        if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {
            context.evaluatePolicy(
                .deviceOwnerAuthentication,
                localizedReason: reason
            ) { success, _ in
                // Callback fires on background thread — dispatch to main
                DispatchQueue.main.async {
                    completion(success)
                }
            }
        } else {
            DispatchQueue.main.async {
                completion(false)
            }
        }
    }

    /// Async version — use with await in SwiftUI views and Tasks
    func authenticateWithBiometrics(
        reason: String = "Authenticate to access secure data"
    ) async -> Bool {
        await withCheckedContinuation { continuation in
            authenticateWithBiometrics(reason: reason) { success in
                continuation.resume(returning: success)
            }
        }
    }
}