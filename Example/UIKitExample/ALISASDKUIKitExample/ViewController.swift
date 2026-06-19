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

class ViewController: UIViewController {

    private var isLoggedIn = false
    private var selectedLanguage: AliSASDKLanguageCode = .vi

    private let stackView = UIStackView()
    private let loginButton = UIButton(configuration: .filled())

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "AliSASDK Example"
        view.backgroundColor = .systemGroupedBackground
        setupUI()

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

        // Login
        updateLoginButton()
        loginButton.addTarget(self, action: #selector(toggleLogin), for: .touchUpInside)
        stackView.addArrangedSubview(loginButton)

        // Language Switcher
        let languageSegment = UISegmentedControl(items: ["VI", "EN"])
        languageSegment.selectedSegmentIndex = 0
        languageSegment.addTarget(self, action: #selector(languageChanged(_:)), for: .valueChanged)
        stackView.addArrangedSubview(languageSegment)

        // --- MiniApp Access ---
        stackView.addArrangedSubview(makeSectionLabel("MiniApp Access"))

        let infoLabel = UILabel()
        infoLabel.numberOfLines = 0
        infoLabel.textColor = .secondaryLabel
        infoLabel.font = .preferredFont(forTextStyle: .footnote)
        infoLabel.text = "Open miniapps by ID with AliSASDK.shared.openMiniApp(miniAppId:). The SDK presents them from the configured navigation controller."
        stackView.addArrangedSubview(infoLabel)
    }

    // MARK: - Actions

    @objc private func toggleLogin() {
        if isLoggedIn {
            AliSASDK.shared.updateUserSession(nil)
            isLoggedIn = false
            print("[Example] User logged out")
        } else {
            let userInfo = AliSASDKUserInfo(
                userId: "user-12345",
                phoneNumber: "+1234567890",
                fullName: "Sample User",
                avatar: "https://example.com/avatar.png"
            )
            if AliSASDK.shared.updateUserSession(userInfo) {
                isLoggedIn = true
                print("[Example] User logged in")
            } else {
                print("[Example] Login failed: invalid user info")
            }
        }
        updateLoginButton()
    }

    @objc private func languageChanged(_ sender: UISegmentedControl) {
        let code: AliSASDKLanguageCode = sender.selectedSegmentIndex == 0 ? .vi : .en
        selectedLanguage = code
        AliSASDK.shared.updateLanguage(code)
        print("[Example] Language changed to \(code.rawValue)")
    }

    // MARK: - Helpers

    private func updateLoginButton() {
        var config: UIButton.Configuration = isLoggedIn ? .tinted() : .filled()
        config.title = isLoggedIn ? "Logout" : "Login (Sample User)"
        config.cornerStyle = .medium
        if isLoggedIn {
            config.baseBackgroundColor = .systemRed
            config.baseForegroundColor = .systemRed
        }
        loginButton.configuration = config
    }

    private func makeSectionLabel(_ text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = .preferredFont(forTextStyle: .headline)
        label.textColor = .label
        return label
    }

}
