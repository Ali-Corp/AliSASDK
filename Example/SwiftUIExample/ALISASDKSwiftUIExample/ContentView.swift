//
//  ContentView.swift
//  ALISASDKSwiftUIExample
//
//  Demonstrates realistic AliSASDK integration and a deterministic UI-test harness.
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

                if model.isUITestMode {
                    harnessSection
                    callbackSection
                } else {
                    miniAppListSection
                }
            }
            .navigationTitle("AliSASDK Example")
        }
        .aliSASDKOverlay()
        .fullScreenCover(isPresented: harnessPresentedBinding) {
            ExampleHarnessNavigationView(model: model)
        }
    }

    private var harnessPresentedBinding: Binding<Bool> {
        Binding(
            get: { model.isHarnessPresented },
            set: { isPresented in
                if !isPresented && model.isHarnessPresented {
                    model.dismissHarness(reason: "system-dismiss")
                }
            }
        )
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

    private var harnessSection: some View {
        Section("E2E Harness") {
            Button("Open Deterministic Fixture") {
                model.launchHarness()
            }
            .accessibilityIdentifier("example.e2e.openFixture")

            Text("Use the local fixture to drive bridge actions without backend dependencies.")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
    }

    private var callbackSection: some View {
        Section("Callback State") {
            statusRow(
                title: "Login requests",
                value: "\(model.loginRequestCount)",
                id: "example.e2e.status.loginRequests"
            )
            statusRow(
                title: "Last JSON",
                value: model.lastReceivedJSON,
                id: "example.e2e.status.lastJSON"
            )
            statusRow(
                title: "Last URL",
                value: model.lastOpenedURL,
                id: "example.e2e.status.lastURL"
            )
            statusRow(
                title: "Last close",
                value: model.lastCloseEvent,
                id: "example.e2e.status.lastClose"
            )
            statusRow(
                title: "Lifecycle",
                value: model.lastLifecycleEvent,
                id: "example.e2e.status.lifecycle"
            )
            statusRow(
                title: "Track event",
                value: model.lastTrackEvent,
                id: "example.e2e.status.trackEvent"
            )
        }
    }

    private var miniAppListSection: some View {
        Section("MiniApp Access") {
            Text("Open miniapps by ID with the SDK. The dynamic server list is removed from this example.")
                .font(.footnote)
                .foregroundStyle(.secondary)
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
    @Published var harnessStack: [LocalMiniAppFixture] = []
    @Published private(set) var loginRequestCount = 0
    @Published private(set) var lastReceivedJSON = "none"
    @Published private(set) var lastOpenedURL = "none"
    @Published private(set) var lastCloseEvent = "none"
    @Published private(set) var lastLifecycleEvent = "none"
    @Published private(set) var lastTrackEvent = "none"

    let isUITestMode = ProcessInfo.processInfo.arguments.contains("--ui-testing")

    var isHarnessPresented: Bool {
        !harnessStack.isEmpty
    }

    var currentUserInfo: AliSASDKUserInfo? {
        guard isLoggedIn else { return nil }
        return AliSASDKUserInfo(
            userId: "user-12345",
            phoneNumber: "+1234567890",
            fullName: "Sample User",
            avatar: "https://example.com/avatar.png"
        )
    }


    func login() {
        if AliSASDK.shared.updateUserSession(currentUserInfo ?? makeLoggedInUser()) {
            isLoggedIn = true
            print("[Example] User logged in")
        } else {
            print("[Example] Login failed: invalid user info")
        }
    }

    func logout() {
        AliSASDK.shared.updateUserSession(nil)
        isLoggedIn = false
        print("[Example] User logged out")
    }

    func updateLanguage(_ code: AliSASDKLanguageCode) {
        AliSASDK.shared.updateLanguage(code)
        print("[Example] Language changed to \(code.rawValue)")
    }

    func launchHarness() {
        lastCloseEvent = "none"
        harnessStack = [.fixtureA]
    }

    func pushHarness(_ fixture: LocalMiniAppFixture) {
        harnessStack.append(fixture)
    }

    func popHarness(reason: String) {
        guard !harnessStack.isEmpty else { return }
        harnessStack.removeLast()
        lastCloseEvent = reason
    }

    func dismissHarness(reason: String) {
        if !harnessStack.isEmpty {
            harnessStack.removeAll()
        }
        lastCloseEvent = reason
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

    func fixtureSDKConfig() -> MiniAppSdkConfig {
        ExampleSDKBootstrap.makeMiniAppSDKConfig()
    }

    func fixtureURL(for fixture: LocalMiniAppFixture) -> URL {
        let directory = FileManager.default.temporaryDirectory
            .appendingPathComponent("AliSASDKExampleFixtures", isDirectory: true)
        try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true, attributes: nil)

        let fileURL = directory.appendingPathComponent("\(fixture.appId).html")
        try? fixture.html.write(to: fileURL, atomically: true, encoding: .utf8)

        guard !fixture.queryParams.isEmpty else { return fileURL }

        var components = URLComponents(url: fileURL, resolvingAgainstBaseURL: false)
        components?.queryItems = fixture.queryParams
            .sorted { $0.key < $1.key }
            .map { URLQueryItem(name: $0.key, value: $0.value) }
        return components?.url ?? fileURL
    }

    private func makeLoggedInUser() -> AliSASDKUserInfo {
        AliSASDKUserInfo(
            userId: "user-12345",
            phoneNumber: "+1234567890",
            fullName: "Sample User",
            avatar: "https://example.com/avatar.png"
        )
    }
}

private struct ExampleHarnessNavigationView: View {
    @ObservedObject var model: ExampleAppModel

    var body: some View {
        if let rootFixture = model.harnessStack.first {
            NavigationStack(path: pushedFixturesBinding) {
                ExampleHarnessMiniAppScreen(model: model, fixture: rootFixture)
                    .navigationDestination(for: LocalMiniAppFixture.self) { fixture in
                        ExampleHarnessMiniAppScreen(model: model, fixture: fixture)
                    }
            }
            .interactiveDismissDisabled(true)
        } else {
            Color.clear
        }
    }

    private var pushedFixturesBinding: Binding<[LocalMiniAppFixture]> {
        Binding(
            get: { Array(model.harnessStack.dropFirst()) },
            set: { pushedFixtures in
                guard let rootFixture = model.harnessStack.first else { return }
                model.harnessStack = [rootFixture] + pushedFixtures
            }
        )
    }
}

private struct ExampleHarnessMiniAppScreen: View {
    @ObservedObject var model: ExampleAppModel
    let fixture: LocalMiniAppFixture

    @State private var handler = MiniAppSUIViewHandler()
    @State private var canGoBack = false
    @State private var miniAppViewProps = MiniAppViewProps()
    @State private var activeAlert: HarnessAlert?

    private let navigationDelegate = MiniAppViewNavigationDelegator()
    private let messageDelegator: MiniAppViewMessageDelegator

    init(model: ExampleAppModel, fixture: LocalMiniAppFixture) {
        self.model = model
        self.fixture = fixture
        self.messageDelegator = MiniAppViewMessageDelegator(
            sdkConfig: model.fixtureSDKConfig(),
            miniAppId: fixture.appId,
            miniAppVersion: fixture.versionId,
            userInfo: model.currentUserInfo,
            languageCode: model.selectedLanguage
        )
    }

    var body: some View {
        MiniAppSUIView(
            urlDevParams: miniAppViewParams(),
            handler: handler
        )
        .modifier(
            MiniAppContainerViewModifier(
                miniAppType: .miniapp,
                miniAppInfo: fixture.miniAppInfo,
                canGoBack: canGoBack,
                onBack: {
                    handler.action = .goBack
                },
                onClose: {
                    closeCurrentFixture(reason: "close-button:\(fixture.appId)")
                },
                onSettings: {},
                miniAppViewProps: $miniAppViewProps
            )
        )
        .overlay(alignment: .bottomLeading) {
            harnessFooter
        }
        .alert(item: $activeAlert) { alert in
            switch alert {
            case .closeConfirmation(let title, let message):
                return Alert(
                    title: Text(title),
                    message: Text(message),
                    primaryButton: .default(Text("OK")) {
                        closeCurrentFixture(reason: "confirm-close:\(fixture.appId)")
                    },
                    secondaryButton: .cancel()
                )
            case .loginRequired:
                return Alert(
                    title: Text("Login Required"),
                    message: Text("The fixture requested login from the host app."),
                    primaryButton: .default(Text("Login")) {
                        model.recordLoginRequest(source: "fixture")
                        model.dismissHarness(reason: "login-requested:\(fixture.appId)")
                    },
                    secondaryButton: .cancel(Text("Close")) {
                        model.dismissHarness(reason: "login-cancelled:\(fixture.appId)")
                    }
                )
            }
        }
        .onAppear {
            model.recordLifecycleEvent("fixture-visible:\(fixture.appId)")
        }
    }

    private var harnessFooter: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("stackDepth:\(model.harnessStack.count)")
                .accessibilityIdentifier("example.e2e.harness.stackDepth")
            Text("navTitle:\(miniAppViewProps.appViewProps?.navigationBar?.title ?? "none")")
                .accessibilityIdentifier("example.e2e.harness.navTitle")
            Text("lastJSON:\(model.lastReceivedJSON)")
                .accessibilityIdentifier("example.e2e.harness.lastJSON")
            Text("lastURL:\(model.lastOpenedURL)")
                .accessibilityIdentifier("example.e2e.harness.lastURL")
        }
        .font(.caption2.monospaced())
        .padding(10)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 12))
        .padding()
    }

    private func miniAppViewParams() -> MiniAppViewParameters.UrlDevParams {
        navigationDelegate.onChangeCanGoBackForward = { back, forward in
            canGoBack = back
            _ = forward
        }

        messageDelegator.sdkConfig = model.fixtureSDKConfig()
        messageDelegator.languageCode = model.selectedLanguage
        messageDelegator.updateUserInfo(model.currentUserInfo)
        messageDelegator.onConfigAppView = { appViewProps in
            miniAppViewProps = MiniAppViewProps(appViewProps: appViewProps)
        }
        messageDelegator.onTriggerLoginUI = {
            model.recordLoginRequest(source: "bridge-trigger")
            return true
        }
        messageDelegator.onLoginRequired = {
            activeAlert = .loginRequired
        }
        messageDelegator.onSendJsonToHostApp = { json, onResolve in
            model.recordReceivedJSON(json, miniAppId: fixture.appId)
            onResolve(true)
        }
        messageDelegator.onOpenWebView = { url in
            model.recordOpenedURL(url)
        }
        messageDelegator.onOpenMiniApp = { appId, queryParams, completionHandler in
            guard let nextFixture = LocalMiniAppFixture(appId: appId, queryParams: queryParams ?? [:]) else {
                completionHandler(.failure(.internalError))
                return
            }

            model.pushHarness(nextFixture)
            completionHandler(.success("SUCCESS"))
        }
        messageDelegator.onShoudCloseMiniApp = { confirmation in
            handleCloseRequest(requiresConfirmation: confirmation)
        }

        return MiniAppViewParameters.UrlDevParams(
            config: MiniAppConfig(
                config: model.fixtureSDKConfig(),
                messageDelegate: messageDelegator,
                navigationDelegate: navigationDelegate
            ),
            type: .miniapp,
            appId: fixture.appId,
            version: fixture.versionId,
            url: model.fixtureURL(for: fixture)
        )
    }

    private func handleCloseRequest(requiresConfirmation: Bool) {
        let closeAlertInfo = handler.closeAlertInfo?()
        let shouldConfirm = requiresConfirmation && (closeAlertInfo?.shouldDisplay ?? false)

        guard shouldConfirm else {
            closeCurrentFixture(reason: "close-request:\(fixture.appId)")
            return
        }

        activeAlert = .closeConfirmation(
            title: closeAlertInfo?.title ?? "Close Fixture",
            message: closeAlertInfo?.description ?? "Confirm closing this fixture."
        )
    }

    private func closeCurrentFixture(reason: String) {
        if model.harnessStack.count == 1 {
            model.dismissHarness(reason: reason)
        } else {
            model.popHarness(reason: reason)
        }
    }
}

struct LocalMiniAppFixture: Hashable, Identifiable {
    let appId: String
    let title: String
    let versionId: String
    let queryParams: [String: String]

    init(appId: String, title: String, versionId: String, queryParams: [String: String] = [:]) {
        self.appId = appId
        self.title = title
        self.versionId = versionId
        self.queryParams = queryParams
    }

    init?(appId: String, queryParams: [String: String]) {
        switch appId {
        case "fixture-a":
            self = .fixtureA
        case "fixture-b":
            self = .fixtureB(queryParams: queryParams)
        default:
            return nil
        }
    }

    static let fixtureA = LocalMiniAppFixture(
        appId: "fixture-a",
        title: "Fixture A",
        versionId: "fixture-a-v1"
    )

    static func fixtureB(queryParams: [String: String] = [:]) -> LocalMiniAppFixture {
        LocalMiniAppFixture(
            appId: "fixture-b",
            title: "Fixture B",
            versionId: "fixture-b-v1",
            queryParams: queryParams
        )
    }

    var id: String {
        let querySuffix = queryParams
            .sorted { $0.key < $1.key }
            .map { "\($0.key)=\($0.value)" }
            .joined(separator: "&")
        return querySuffix.isEmpty ? appId : "\(appId)?\(querySuffix)"
    }

    var miniAppInfo: MiniAppInfo {
        MiniAppInfo(
            id: appId,
            displayName: title,
            icon: URL(string: "https://example.com/\(appId).png")!,
            version: Version(versionTag: "1.0.0", versionId: versionId),
            promotionalImageUrl: "",
            promotionalText: ""
        )
    }

    var html: String {
        switch appId {
        case "fixture-b":
            return """
            <!doctype html>
            <html lang="en">
            <head>
              <meta charset="utf-8">
              <meta name="viewport" content="width=device-width, initial-scale=1">
              <title>Fixture B</title>
              <style>
                body { font-family: -apple-system, BlinkMacSystemFont, sans-serif; padding: 24px; background: #f6f7fb; color: #1e1f24; }
                button { display: block; width: 100%; margin: 12px 0; padding: 14px; border: 0; border-radius: 12px; background: #1d4ed8; color: white; font-size: 16px; }
                .card { padding: 16px; background: white; border-radius: 16px; box-shadow: 0 10px 30px rgba(15, 23, 42, 0.08); }
              </style>
              <script>
                function setOutput(value) {
                  document.getElementById('output').textContent = value;
                }

                function waitForBridge() {
                  if (window.MiniAppBridge) {
                    setOutput('bridge-ready');
                    return;
                  }
                  setTimeout(waitForBridge, 50);
                }

                function closeNow() {
                  window.MiniAppBridge.closeMiniApp(false);
                  setOutput('close-requested');
                }

                document.addEventListener('DOMContentLoaded', function () {
                  const params = new URLSearchParams(window.location.search);
                  document.getElementById('query').textContent = 'query-source:' + (params.get('source') || 'none');
                  waitForBridge();
                });
              </script>
            </head>
            <body>
              <div class="card">
                <h1>Fixture B</h1>
                <p id="query">query-source:none</p>
                <p id="output">loading</p>
                <button aria-label="Close Without Confirmation" onclick="closeNow()">Close Without Confirmation</button>
              </div>
            </body>
            </html>
            """
        default:
            return """
            <!doctype html>
            <html lang="en">
            <head>
              <meta charset="utf-8">
              <meta name="viewport" content="width=device-width, initial-scale=1">
              <title>Fixture A</title>
              <style>
                body { font-family: -apple-system, BlinkMacSystemFont, sans-serif; padding: 24px; background: linear-gradient(180deg, #f8fafc 0%, #e2e8f0 100%); color: #0f172a; }
                button { display: block; width: 100%; margin: 12px 0; padding: 14px; border: 0; border-radius: 12px; background: #111827; color: white; font-size: 16px; }
                .card { padding: 18px; background: rgba(255,255,255,0.92); border-radius: 18px; box-shadow: 0 18px 50px rgba(15, 23, 42, 0.12); }
              </style>
              <script>
                function setOutput(value) {
                  document.getElementById('output').textContent = value;
                }

                function waitForBridge() {
                  if (window.MiniAppBridge) {
                    setOutput('bridge-ready');
                    return;
                  }
                  setTimeout(waitForBridge, 50);
                }

                function readLocale() {
                  window.MiniAppBridge.getHostEnvironmentInfo().then(function (info) {
                    setOutput('locale:' + info.hostLocale);
                  }).catch(function () {
                    setOutput('locale:error');
                  });
                }

                function configureHeader() {
                  window.MiniAppBridge.configAppView({
                    navigationBar: {
                      hide: false,
                      title: 'Configured Harness',
                      titleAlign: 'center',
                      leftButton: 'back'
                    },
                    ignoreSafeArea: {
                      top: false,
                      bottom: false
                    }
                  });
                  setOutput('configured-header');
                }

                function sendJson() {
                  window.MiniAppBridge.sendJsonToHostapp(JSON.stringify({ type: 'fixture-ping', source: 'fixture-a' }));
                  setOutput('json-sent');
                }

                function openWebView() {
                  window.MiniAppBridge.openWebView('https://example.com/e2e?fixture=fixture-a');
                  setOutput('webview-requested');
                }

                function openNestedFixture() {
                  window.MiniAppBridge.openMiniApp({
                    appId: 'fixture-b',
                    queryParams: {
                      source: 'fixture-a'
                    }
                  });
                  setOutput('nested-requested');
                }

                function closeWithConfirmation() {
                  window.MiniAppBridge.setCloseAlert({
                    shouldDisplay: true,
                    title: 'Close Fixture',
                    description: 'Confirm closing this fixture'
                  });
                  window.MiniAppBridge.closeMiniApp(true);
                  setOutput('close-confirmation-requested');
                }

                function requestLogin() {
                  window.MiniAppBridge.getMauid().then(function (value) {
                    setOutput('mauid:' + value);
                  }).catch(function () {
                    setOutput('login-requested');
                  });
                }

                document.addEventListener('DOMContentLoaded', waitForBridge);
              </script>
            </head>
            <body>
              <div class="card">
                <h1>Fixture A</h1>
                <p id="output">loading</p>
                <button aria-label="Read Host Locale" onclick="readLocale()">Read Host Locale</button>
                <button aria-label="Configure Native Header" onclick="configureHeader()">Configure Native Header</button>
                <button aria-label="Send JSON To Host" onclick="sendJson()">Send JSON To Host</button>
                <button aria-label="Open WebView" onclick="openWebView()">Open WebView</button>
                <button aria-label="Open Nested Fixture" onclick="openNestedFixture()">Open Nested Fixture</button>
                <button aria-label="Require Login" onclick="requestLogin()">Require Login</button>
                <button aria-label="Close With Confirmation" onclick="closeWithConfirmation()">Close With Confirmation</button>
              </div>
            </body>
            </html>
            """
        }
    }
}

private enum HarnessAlert: Identifiable {
    case closeConfirmation(title: String, message: String)
    case loginRequired

    var id: String {
        switch self {
        case .closeConfirmation(let title, _):
            return "close:\(title)"
        case .loginRequired:
            return "login-required"
        }
    }
}

extension LocalMiniAppFixture {
    static func == (lhs: LocalMiniAppFixture, rhs: LocalMiniAppFixture) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

#Preview {
    ContentView(model: ExampleAppModel())
}
