//
        //
    //  Project: Keychain_SwiftUI
    //  File: ContentView.swift
    //  Created by Noah Carpenter 
    //
    //  📺 YouTube: Noah Does Coding
    //  https://www.youtube.com/@NoahDoesCoding97
    //  Like and Subscribe for coding tutorials and fun! 💻✨
    //  Dream Big. Code Bigger 🚀
    //

    
//
//  ContentView.swift
//  KeychainDemo
//  Demonstrates KeychainHelper, @KeychainStorage, and biometric auth
//

import SwiftUI

struct ContentView: View {
    
    // Stored in the Keychain — encrypted, hardware-backed
    // Works exactly like @AppStorage but secure
    @KeychainStorage("secretNote") var secretNote
    
    // Session lock state — resets on app relaunch
    @State private var isUnlocked = false
    @State private var inputText = ""
    
    private let helper = KeychainHelper.shared
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                if isUnlocked {
                    // MARK: Unlocked Content
                    unlockedView
                } else {
                    // MARK: Locked Content
                    lockedView
                }
            }
            .padding()
            .navigationTitle("Keychain Demo")
        }
    }
    
    // MARK: - Locked View
    
    private var lockedView: some View {
        VStack(spacing: 16) {
            Spacer()
            
            Image(systemName: "lock.fill")
                .font(.system(size: 60))
                .foregroundStyle(.secondary)
            
            Text("Locked")
                .font(.title.bold())
            
            Text("Authenticate to view your secure data")
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            
            Spacer()
            
            // Trigger FaceID / TouchID / Passcode
            Button {
                Task {
                    let success = await helper.authenticateWithBiometrics(
                        reason: "Unlock your secure notes"
                    )
                    if success { isUnlocked = true }
                }
            } label: {
                Label("Unlock with FaceID", systemImage: "faceid")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            
            Spacer()
        }
    }
    
    // MARK: - Unlocked View
    
    private var unlockedView: some View {
        VStack(spacing: 16) {
            Image(systemName: "lock.open.fill")
                .font(.system(size: 50))
                .foregroundStyle(.green)
            
            // Display stored secret from Keychain
            GroupBox("Stored Secret") {
                Text(secretNote.isEmpty ? "No data stored" : secretNote)
                    .font(.system(.body, design: .monospaced))
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            // Input field for new data
            TextField("Enter secure note", text: $inputText)
                .textFieldStyle(.roundedBorder)
            
            HStack(spacing: 12) {
                // Save to Keychain (encrypted)
                Button("Save") {
                    secretNote = inputText
                    inputText = ""
                }
                .buttonStyle(.borderedProminent)
                
                // Delete from Keychain
                Button("Delete") {
                    secretNote = ""
                }
                .buttonStyle(.bordered)
                .tint(.red)
            }
            
            Spacer()
            
            // Re-lock the view
            Button("Lock") {
                isUnlocked = false
            }
            .buttonStyle(.bordered)
            .tint(.orange)
        }
    }
}

// MARK: - Preview

#Preview {
    ContentView()
}
