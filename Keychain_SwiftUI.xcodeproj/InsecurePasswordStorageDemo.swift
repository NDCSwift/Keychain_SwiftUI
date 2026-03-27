import SwiftUI

/// WARNING: This file intentionally demonstrates INSECURE ways to store passwords.
/// Never store real credentials in UserDefaults or AppStorage.
/// Use the Keychain instead. Keychain is encrypted and access-controlled by the system.
///
/// This demo uses fake values only to illustrate the risk.
struct InsecurePasswordStorageDemo: View {
    // INSECURE: @AppStorage writes to UserDefaults under the hood.
    // Anything saved here is accessible in plaintext via UserDefaults.
    @AppStorage("fake_password_app_storage") private var appStoragePassword: String = ""

    // INSECURE: Direct use of UserDefaults for secrets.
    private let defaults = UserDefaults.standard
    @State private var defaultsPassword: String = ""

    // UI state for entering a fake password
    @State private var inputPassword: String = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Insecure Password Storage (Demo)")
                .font(.headline)

            Text("Do NOT store real passwords in AppStorage or UserDefaults. Use Keychain.")
                .font(.subheadline)
                .foregroundStyle(.red)

            SecureField("Enter fake password", text: $inputPassword)
                .textContentType(.password)
                .privacySensitive()

            HStack {
                Button("Save to AppStorage (INSECURE)") {
                    appStoragePassword = inputPassword
                }
                Button("Read from AppStorage") {
                    inputPassword = appStoragePassword
                }
            }

            HStack {
                Button("Save to UserDefaults (INSECURE)") {
                    defaults.set(inputPassword, forKey: "fake_password_user_defaults")
                }
                Button("Read from UserDefaults") {
                    defaultsPassword = defaults.string(forKey: "fake_password_user_defaults") ?? ""
                    inputPassword = defaultsPassword
                }
            }

            Divider()

            Group {
                Text("Current AppStorage value (INSECURE): \(appStoragePassword)")
                    .font(.footnote)
                Text("Current UserDefaults value (INSECURE): \(defaultsPassword)")
                    .font(.footnote)
            }
            .privacySensitive()

            Divider()

            Text("Secure alternative: Keychain")
                .font(.headline)
            Text("Store secrets in the Keychain using APIs like SecItemAdd / SecItemUpdate / SecItemCopyMatching or a small wrapper. Keychain encrypts and protects your data.")
                .font(.footnote)

            // Minimal pseudo-usage note (no Keychain code here to keep this file focused)
            Text("Example: save password with SecItemAdd, read with SecItemCopyMatching.")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
    }
}

#Preview {
    InsecurePasswordStorageDemo()
}
