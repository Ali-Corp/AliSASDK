//
//  ViewController.swift
//  ALISASDKUIKitExample
//
//  Demonstrates realistic AliSASDK integration in UIKit:
//  - Login/logout mock
//  - Language switcher
//  - UIKit MiniApp presentation via configure(navigationController:)
//

import UIKit
import AliSASDK

class ViewController: UIViewController, UITextFieldDelegate {

    private let model: ExampleAppModel

    private let stackView = UIStackView()
    private let loggedInLabel = UILabel()
    private let loginButton = UIButton(configuration: .filled())
    private let languageSegment = UISegmentedControl(items: ["VI", "EN"])
    private let miniAppIdField = UITextField()
    private let openMiniAppButton = UIButton(configuration: .filled())
    private let loginRequestsValueLabel = UILabel()
    private let lastJSONValueLabel = UILabel()
    private let lastURLValueLabel = UILabel()
    private let lifecycleValueLabel = UILabel()
    private let trackEventValueLabel = UILabel()

    required init?(coder: NSCoder) {
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            model = appDelegate.appModel
        } else {
            model = ExampleAppModel()
        }
        super.init(coder: coder)
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "AliSASDK Example"
        view.backgroundColor = .systemGroupedBackground
        setupUI()
        bindModel()
        refreshUI()

        // UIKit MiniApp presentation: no SwiftUI overlay needed.
        if let navigationController {
            AliSASDK.shared.configure(navigationController: navigationController)
        }
    }

    // MARK: - UI Setup

    private func setupUI() {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)

        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(stackView)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 16),
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -16),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -16),
            stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -32),
        ])

        // --- Actions ---
        stackView.addArrangedSubview(makeSectionLabel("Actions"))

        loggedInLabel.text = "Logged in as Sample User"
        loggedInLabel.textColor = .secondaryLabel
        loggedInLabel.font = .preferredFont(forTextStyle: .body)
        stackView.addArrangedSubview(loggedInLabel)

        loginButton.addTarget(self, action: #selector(toggleLogin), for: .touchUpInside)
        stackView.addArrangedSubview(loginButton)

        languageSegment.accessibilityIdentifier = "example.language.picker"
        languageSegment.addTarget(self, action: #selector(languageChanged(_:)), for: .valueChanged)
        stackView.addArrangedSubview(languageSegment)

        // --- MiniApp Access ---
        stackView.addArrangedSubview(makeSectionLabel("MiniApp Access"))

        miniAppIdField.borderStyle = .roundedRect
        miniAppIdField.placeholder = "MiniApp ID"
        miniAppIdField.autocorrectionType = .no
        miniAppIdField.autocapitalizationType = .none
        miniAppIdField.clearButtonMode = .whileEditing
        miniAppIdField.returnKeyType = .go
        miniAppIdField.delegate = self
        miniAppIdField.accessibilityIdentifier = "example.miniapp.idField"
        miniAppIdField.addTarget(self, action: #selector(miniAppIdChanged(_:)), for: .editingChanged)
        stackView.addArrangedSubview(miniAppIdField)

        var openConfig = UIButton.Configuration.filled()
        openConfig.title = "Open MiniApp"
        openConfig.cornerStyle = .medium
        openMiniAppButton.configuration = openConfig
        openMiniAppButton.accessibilityIdentifier = "example.miniapp.open"
        openMiniAppButton.addTarget(self, action: #selector(openMiniApp), for: .touchUpInside)
        stackView.addArrangedSubview(openMiniAppButton)

        // --- Callback State ---
        stackView.addArrangedSubview(makeSectionLabel("Callback State"))
        stackView.addArrangedSubview(makeStatusRow(
            title: "Login requests",
            valueLabel: loginRequestsValueLabel,
            id: "example.status.loginRequests"
        ))
        stackView.addArrangedSubview(makeStatusRow(
            title: "Last JSON",
            valueLabel: lastJSONValueLabel,
            id: "example.status.lastJSON"
        ))
        stackView.addArrangedSubview(makeStatusRow(
            title: "Last URL",
            valueLabel: lastURLValueLabel,
            id: "example.status.lastURL"
        ))
        stackView.addArrangedSubview(makeStatusRow(
            title: "Lifecycle",
            valueLabel: lifecycleValueLabel,
            id: "example.status.lifecycle"
        ))
        stackView.addArrangedSubview(makeStatusRow(
            title: "Track event",
            valueLabel: trackEventValueLabel,
            id: "example.status.trackEvent"
        ))
    }

    private func bindModel() {
        model.onChange = { [weak self] in
            self?.refreshUI()
        }
    }

    // MARK: - Actions

    @objc private func toggleLogin() {
        if model.isLoggedIn {
            model.logout()
            print("[Example] User logged out")
        } else {
            model.login()
            print(model.isLoggedIn ? "[Example] User logged in" : "[Example] Login failed: invalid user info")
        }
    }

    @objc private func languageChanged(_ sender: UISegmentedControl) {
        let code: AliSASDKLanguageCode = sender.selectedSegmentIndex == 0 ? .vi : .en
        model.selectedLanguage = code
        model.updateLanguage(code)
        print("[Example] Language changed to \(code.rawValue)")
    }

    @objc private func miniAppIdChanged(_ sender: UITextField) {
        model.miniAppIdInput = sender.text ?? ""
    }

    @objc private func openMiniApp() {
        view.endEditing(true)
        model.openMiniApp()
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if !model.miniAppIdInput.trimmingCharacters(in: .whitespaces).isEmpty {
            model.openMiniApp()
        }
        return true
    }

    // MARK: - Helpers

    private func refreshUI() {
        loggedInLabel.isHidden = !model.isLoggedIn
        updateLoginButton()

        languageSegment.selectedSegmentIndex = model.selectedLanguage == .vi ? 0 : 1

        if miniAppIdField.text != model.miniAppIdInput {
            miniAppIdField.text = model.miniAppIdInput
        }
        openMiniAppButton.isEnabled = !model.miniAppIdInput.trimmingCharacters(in: .whitespaces).isEmpty

        loginRequestsValueLabel.text = "\(model.loginRequestCount)"
        lastJSONValueLabel.text = model.lastReceivedJSON
        lastURLValueLabel.text = model.lastOpenedURL
        lifecycleValueLabel.text = model.lastLifecycleEvent
        trackEventValueLabel.text = model.lastTrackEvent
    }

    private func updateLoginButton() {
        var config: UIButton.Configuration = model.isLoggedIn ? .tinted() : .filled()
        config.title = model.isLoggedIn ? "Logout" : "Login (Sample User)"
        config.cornerStyle = .medium
        if model.isLoggedIn {
            config.baseBackgroundColor = .systemRed
            config.baseForegroundColor = .systemRed
        }
        loginButton.configuration = config
        loginButton.accessibilityIdentifier = model.isLoggedIn ? "example.auth.logout" : "example.auth.login"
    }

    private func makeSectionLabel(_ text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = .preferredFont(forTextStyle: .headline)
        label.textColor = .label
        return label
    }

    private func makeStatusRow(title: String, valueLabel: UILabel, id: String) -> UIView {
        let row = UIStackView()
        row.axis = .vertical
        row.spacing = 4

        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .preferredFont(forTextStyle: .caption1)
        titleLabel.textColor = .secondaryLabel
        row.addArrangedSubview(titleLabel)

        valueLabel.font = .monospacedSystemFont(ofSize: UIFont.preferredFont(forTextStyle: .footnote).pointSize, weight: .regular)
        valueLabel.textColor = .label
        valueLabel.numberOfLines = 0
        valueLabel.accessibilityIdentifier = id
        row.addArrangedSubview(valueLabel)

        return row
    }
}

final class ExampleAppModel {
    var onChange: (() -> Void)?

    var selectedLanguage: AliSASDKLanguageCode = .vi {
        didSet { notifyChange() }
    }
    private(set) var isLoggedIn = false {
        didSet { notifyChange() }
    }
    var miniAppIdInput = "" {
        didSet { notifyChange() }
    }
    private(set) var loginRequestCount = 0 {
        didSet { notifyChange() }
    }
    private(set) var lastReceivedJSON = "none" {
        didSet { notifyChange() }
    }
    private(set) var lastOpenedURL = "none" {
        didSet { notifyChange() }
    }
    private(set) var lastLifecycleEvent = "none" {
        didSet { notifyChange() }
    }
    private(set) var lastTrackEvent = "none" {
        didSet { notifyChange() }
    }

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

    private func notifyChange() {
        if Thread.isMainThread {
            onChange?()
        } else {
            DispatchQueue.main.async { [weak self] in
                self?.onChange?()
            }
        }
    }
}
