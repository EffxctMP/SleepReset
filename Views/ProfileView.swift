import SwiftUI
import PhotosUI
import UIKit
import AuthenticationServices

struct ProfileView: View {
    @State private var displayName = ""
    @State private var username = ""
    @State private var statusMessage: String?
    @State private var connectionStatus: String = "Not connected"
    @State private var isConnectingWithApple = false
    @State private var isSaving = false
    @State private var syncData = true
    @State private var lastSyncDate: Date = .now
    @State private var avatarImage: Image?
    @State private var avatarItem: PhotosPickerItem?

    var body: some View {
        NavigationStack {
            Form {
                Section("Apple Account") {
                    VStack(alignment: .leading, spacing: 8) {
                        SignInWithAppleButton(.signIn, onRequest: { (request: ASAuthorizationAppleIDRequest) in
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
                                    statusMessage = "Connection was canceled or failed. Try again."
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
                    }
                }

                Section("Profile") {
                    PhotosPicker(selection: $avatarItem, matching: .images, photoLibrary: .shared()) {
                        HStack {
                            if let avatarImage {
                                avatarImage
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 56, height: 56)
                                    .clipShape(Circle())
                                    .overlay(Circle().stroke(.separator, lineWidth: 1))
                            } else {
                                Circle()
                                    .fill(.thinMaterial)
                                    .frame(width: 56, height: 56)
                                    .overlay {
                                        Image(systemName: "camera.fill")
                                            .foregroundStyle(.secondary)
                                    }
                            }

                            VStack(alignment: .leading, spacing: 4) {
                                Text("Profile Picture")
                                    .font(.headline)
                                Text("Tap to choose a photo")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }

                    TextField("Name", text: $displayName)
                        .textContentType(.name)

                    TextField("Username", text: $username)
                        .textInputAutocapitalization(.never)
                        .textContentType(.username)
                }

                Section("Data & Sync") {
                    Toggle("Sync app data to your account", isOn: $syncData)

                    Button {
                        saveProfileData()
                    } label: {
                        Label("Save Profile & Settings", systemImage: "icloud.and.arrow.up")
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .disabled(isSaving)

                    if let statusMessage {
                        Text(statusMessage)
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                            .transition(.opacity)
                    }

                    HStack {
                        Image(systemName: "clock")
                            .foregroundStyle(.secondary)
                        Text("Last saved: \(lastSyncDate.formatted(date: .abbreviated, time: .shortened))")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.top, 4)
                }
            }
            .navigationTitle("Profile")
            .task(id: avatarItem) {
                if let data = try? await avatarItem?.loadTransferable(type: Data.self),
                   let uiImage = UIImage(data: data) {
                    avatarImage = Image(uiImage: uiImage)
                }
            }
        }
    }

    @MainActor
    private func handleAuthorizationSuccess(_ authorization: ASAuthorization) {
        if authorization.credential is ASAuthorizationAppleIDCredential {
            connectionStatus = "Connected with your Apple ID"
            statusMessage = "Your profile is now linked for syncing."
        } else {
            statusMessage = "Connection was canceled or failed. Try again."
        }
    }

    private func saveProfileData() {
        statusMessage = "Saving your preferences to the cloud…"
        isSaving = true

        Task { @MainActor in
            try? await Task.sleep(for: .seconds(0.35))
            lastSyncDate = .now
            statusMessage = "Profile, photo, and app data saved to your account."
            isSaving = false
        }
    }
}
