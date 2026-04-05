# 🔑 Keychain SwiftUI

A SwiftUI reference project showing how to securely store, read, and delete data using the iOS Keychain, with Face ID / Touch ID biometric authentication and a custom `@KeychainStorage` property wrapper.

---

## 🤔 What this is

This project wraps the low-level iOS Keychain Services API (C-style `CFDictionary` interface) in a clean, Swift-idiomatic layer. It includes a thread-safe `KeychainHelper` singleton, a `@KeychainStorage` property wrapper for SwiftUI-friendly access, and biometric authentication via `LocalAuthentication` — all wired into a working demo UI.

## ✅ Why you'd use it

- **Drop-in Keychain wrapper** — `KeychainHelper.shared` handles save, read, and delete with sensible error handling
- **`@KeychainStorage` property wrapper** — use Keychain values in SwiftUI views the same way you use `@AppStorage`
- **Face ID / Touch ID support** — biometric auth with a passcode fallback, in both callback and `async/await` forms
- **Swift 6 concurrency-safe** — `KeychainHelper` is `final` and `Sendable`, ready for strict concurrency
- **No third-party dependencies** — only `Security` and `LocalAuthentication` frameworks

## 📺 Watch on YouTube

[![Watch on YouTube](https://img.shields.io/badge/YouTube-Watch%20the%20Tutorial-red?style=for-the-badge&logo=youtube)](https://youtu.be/K0UQ-LJMRnE)

> This project was built for the [NoahDoesCoding YouTube channel](https://www.youtube.com/@NoahDoesCoding97). Subscribe for weekly SwiftUI tutorials.

---

## 🚀 Getting Started

### 1. Clone the Repo
```bash
git clone https://github.com/NDCSwift/Keychain_SwiftUI.git
cd Keychain_SwiftUI
```
Or select "Clone Git Repository…" when Xcode launches.

### 2. Open in Xcode
- Double-click `Keychain_SwiftUI.xcodeproj`.

### 3. Set Your Development Team

In Xcode, navigate to: **TARGET → Signing & Capabilities → Team**
- Select your personal or organizational team.

### 4. Update the Bundle Identifier
- Change `com.example.MyApp` to a unique identifier (e.g., `com.yourname.KeychainDemo`).

### 5. Run
Face ID prompt requires a real device. All other features work on the simulator.

---

## 🛠️ Notes

- Add `NSFaceIDUsageDescription` to your `Info.plist` if prompting for Face ID
- Keychain items are scoped to the app's bundle identifier by default
- If you see a code signing error, check that Team and Bundle ID are set

## 📦 Requirements

- Xcode 15+
- iOS 17+
- No third-party dependencies

📺 [Watch the guide on YouTube](https://youtu.be/K0UQ-LJMRnE)
