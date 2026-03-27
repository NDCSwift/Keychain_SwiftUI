//
        //
    //  Project: Keychain_SwiftUI
    //  File: KeychainStorage.swift
    //  Created by Noah Carpenter 
    //
    //  📺 YouTube: Noah Does Coding
    //  https://www.youtube.com/@NoahDoesCoding97
    //  Like and Subscribe for coding tutorials and fun! 💻✨
    //  Dream Big. Code Bigger 🚀
    //

    


//
//  KeychainStorage.swift
//  KeychainDemo
//  A @propertyWrapper that works like @AppStorage but stores to the Keychain
//  Usage: @KeychainStorage("authToken") var token: String
//

import SwiftUI

/// Property wrapper that reads and writes a String to the iOS Keychain
/// Conforms to DynamicProperty so SwiftUI view updates trigger on changes
/// The stored value is encrypted at rest by the Secure Enclave
@propertyWrapper
struct KeychainStorage: DynamicProperty {

    // The Keychain key used to store and retrieve the value
    private let key: String
    // Reference to the KeychainHelper singleton
    private let helper = KeychainHelper.shared

    // Internal @State drives SwiftUI view updates
    // When this changes, any view using this wrapper re-renders
    @State private var value: String

    /// Initialize with a Keychain key and optional default value
    /// - Parameters:
    ///   - wrappedValue: Default value if nothing exists in the Keychain
    ///   - key: The Keychain key to store this value under
    init(wrappedValue: String = "", _ key: String) {
        self.key = key
        // Hydrate from Keychain on creation — persists across app launches
        let existing = KeychainHelper.shared.readString(for: key)
        self._value = State(initialValue: existing ?? wrappedValue)
    }

    var wrappedValue: String {
        get { value }
        nonmutating set {
            value = newValue
            if newValue.isEmpty {
                // Empty string = delete the Keychain entry
                helper.delete(for: key)
            } else {
                // Save the new value to encrypted Keychain storage
                helper.save(newValue, for: key)
            }
        }
    }

    /// Provides a Binding<String> for use with TextField and other controls
    /// Usage: TextField("Token", text: $token)
    var projectedValue: Binding<String> {
        Binding(
            get: { wrappedValue },
            set: { wrappedValue = $0 }
        )
    }
}