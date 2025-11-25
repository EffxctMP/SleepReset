import SwiftUI
import AuthenticationServices

struct SettingsView: View {
    @AppStorage("isDarkMode") private var isDarkMode = false
    @AppStorage("themeColorRaw") private var themeColorRaw = AppTheme.default.rawValue
    @State private var connectionStatus: String = "Not connected"
    @State private var statusMessage: String?
    @State private var isConnectingWithApple = false

    private var appTheme: AppTheme {
        AppTheme(rawValue: themeColorRaw) ?? .default
    }

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Appearance")) {
                    Toggle("Dark Mode", isOn: $isDarkMode)
                        .tint(appTheme.accent)

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Theme Color")
                            .font(.headline)

                        LazyVGrid(
                            columns: [GridItem(.adaptive(minimum: 120), spacing: 12)],
                            spacing: 12
                        ) {
                            ForEach(AppTheme.allCases) { option in
                                Button {
                                    themeColorRaw = option.rawValue
                                } label: {
                                    HStack {
                                        Circle()
                                            .fill(option.accent.gradient)
                                            .frame(width: 22, height: 22)

                                        Text(option.displayName)
                                            .fontWeight(.semibold)

                                        Spacer()

                                        if option.rawValue == themeColorRaw {
                                            Image(systemName: "checkmark.circle.fill")
                                                .foregroundStyle(option.accent)
                                        }
                                    }
                                    .padding(.vertical, 8)
                                    .padding(.horizontal, 12)
                                    .frame(maxWidth: .infinity)
                                    .background(.ultraThinMaterial)
                                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                                    .shadow(
                                        color: Color.black.opacity(0.08),
                                        radius: 6,
                                        x: 0,
                                        y: 4
                                    )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    .pickerStyle(.navigationLink)
                }

                Section("Apple Account") {
                    VStack(alignment: .leading, spacing: 8) {
                        SignInWithAppleButton(.continue, onRequest: { (request: ASAuthorizationAppleIDRequest) in
                            statusMessage = nil
                            isConnectingWithApple = true
                            request.requestedScopes = [.fullName, .email]
                        }, onCompletion: { result in
                            Task { @MainActor in
                                isConnectingWithApple = false
                                switch result {
                                case .success(let authorization):
                                    handleAuthorizationSuccess(authorization)
                                case .failure:
                                    statusMessage = "Apple connection failed or was canceled."
                                }
                            }
                        })
                        .signInWithAppleButtonStyle(.black)
                        .frame(maxWidth: .infinity, minHeight: 44)
                        .overlay {
                            if isConnectingWithApple {
                                ProgressView()
                                    .progressViewStyle(.circular)
                                    .tint(.white)
                            }
                        }
                        .disabled(isConnectingWithApple)

                        HStack {
                            Image(systemName: connectionStatus == "Not connected" ? "xmark.circle" : "checkmark.circle")
                                .foregroundStyle(connectionStatus == "Not connected" ? Color.secondary : Color.green)
                            Text(connectionStatus)
                                .foregroundStyle(.secondary)
                        }
                        .font(.footnote)

                        if let statusMessage {
                            Text(statusMessage)
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .navigationTitle("Settings")
            .tint(appTheme.accent)
        }
    }

    @MainActor
    private func handleAuthorizationSuccess(_ authorization: ASAuthorization) {
        if authorization.credential is ASAuthorizationAppleIDCredential {
            connectionStatus = "Connected with your Apple ID"
            statusMessage = "Your preferences will sync to this account."
        } else {
            statusMessage = "Apple connection failed or was canceled."
        }
    }
}
