//
//  ContentView.swift
//  ALISASDKSwiftUIExample
//
//  Demonstrates realistic AliSASDK integration using only the public SDK API.
//

import SwiftUI
import Combine
import AliSASDK

struct ContentView: View {
    @ObservedObject var model: ExampleAppModel

    var body: some View {
        NavigationStack {
            List {
                actionsSection
                openMiniAppSection
                callbackSection
            }
            .navigationTitle("AliSASDK Example")
        }
        .aliSASDKOverlay()
    }

    private var actionsSection: some View {
        Section("Actions") {
            if model.isLoggedIn {
                Text("Logged in as Sample User")
                    .foregroundStyle(.secondary)

                Button("Logout", role: .destructive) {
                    model.logout()
                }
                .accessibilityIdentifier("example.auth.logout")
            } else {
                Button("Login (Sample User)") {
                    model.login()
                }
                .accessibilityIdentifier("example.auth.login")
            }

            Picker("Language", selection: $model.selectedLanguage) {
                Text("VI").tag(AliSASDKLanguageCode.vi)
                Text("EN").tag(AliSASDKLanguageCode.en)
            }
            .pickerStyle(.segmented)
            .accessibilityIdentifier("example.language.picker")
            .onChange(of: model.selectedLanguage) { _, newValue in
                model.updateLanguage(newValue)
            }
        }
    }

    private var openMiniAppSection: some View {
        Section("MiniApp Access") {
            TextField("MiniApp ID", text: $model.miniAppIdInput)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
                .accessibilityIdentifier("example.miniapp.idField")

            Button("Open MiniApp") {
                model.openMiniApp()
            }
            .disabled(model.miniAppIdInput.trimmingCharacters(in: .whitespaces).isEmpty)
            .accessibilityIdentifier("example.miniapp.open")
        }
    }

    private var callbackSection: some View {
        Section("Callback State") {
            statusRow(
                title: "Login requests",
                value: "\(model.loginRequestCount)",
                id: "example.status.loginRequests"
            )
            statusRow(
                title: "Last JSON",
                value: model.lastReceivedJSON,
                id: "example.status.lastJSON"
            )
            statusRow(
                title: "Last URL",
                value: model.lastOpenedURL,
                id: "example.status.lastURL"
            )
            statusRow(
                title: "Lifecycle",
                value: model.lastLifecycleEvent,
                id: "example.status.lifecycle"
            )
            statusRow(
                title: "Track event",
                value: model.lastTrackEvent,
                id: "example.status.trackEvent"
            )
        }
    }

    private func statusRow(title: String, value: String, id: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.footnote.monospaced())
                .accessibilityIdentifier(id)
        }
    }
}

@MainActor
final class ExampleAppModel: ObservableObject {
    @Published var selectedLanguage: AliSASDKLanguageCode = .vi
    @Published private(set) var isLoggedIn = false
    @Published var miniAppIdInput = ""
    @Published private(set) var loginRequestCount = 0
    @Published private(set) var lastReceivedJSON = "none"
    @Published private(set) var lastOpenedURL = "none"
    @Published private(set) var lastLifecycleEvent = "none"
    @Published private(set) var lastTrackEvent = "none"

    var currentUserInfo: AliSASDKUserInfo? {
        guard isLoggedIn else { return nil }
        return makeLoggedInUser()
    }

    func login() {
        if AliSASDK.shared.updateUserSession(makeLoggedInUser()) {
            isLoggedIn = true
        }
    }

    func logout() {
        AliSASDK.shared.updateUserSession(nil)
        isLoggedIn = false
    }

    func updateLanguage(_ code: AliSASDKLanguageCode) {
        AliSASDK.shared.updateLanguage(code)
    }

    func openMiniApp() {
        let id = miniAppIdInput.trimmingCharacters(in: .whitespaces)
        guard !id.isEmpty else { return }
        Task {
            try? await AliSASDK.shared.openMiniApp(miniAppId: id)
        }
    }

    func recordLoginRequest(source: String) {
        loginRequestCount += 1
        lastLifecycleEvent = "login-request:\(source)"
    }

    func recordReceivedJSON(_ json: String, miniAppId: String) {
        lastReceivedJSON = "\(miniAppId):\(json)"
    }

    func recordOpenedURL(_ url: String) {
        lastOpenedURL = url
    }

    func recordLifecycleEvent(_ value: String) {
        lastLifecycleEvent = value
    }

    func recordTrackEvent(name: String, params: [String: String]?) {
        let formattedParams = params?
            .sorted { $0.key < $1.key }
            .map { "\($0.key)=\($0.value)" }
            .joined(separator: ",") ?? "none"
        lastTrackEvent = "\(name)[\(formattedParams)]"
    }

    private func makeLoggedInUser() -> AliSASDKUserInfo {
        AliSASDKUserInfo(
            userId: "user-12345",
            phoneNumber: "1234567890",
            fullName: "Sample User",
            avatar: "https://example.com/avatar.png"
        )
    }
}

#Preview {
    ContentView(model: ExampleAppModel())
}
