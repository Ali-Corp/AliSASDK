//
//  AppDelegate.swift
//  ALISASDKUIKitExample
//
//  Demonstrates AliSASDK configuration at app launch and orientation lock forwarding.
//

import UIKit
import AliSASDK

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    /// Shared example state used by UIKit UI and SDK delegate callbacks.
    let appModel = ExampleAppModel()

    /// The delegate must be retained for the SDK's lifetime.
    lazy var sdkDelegate = SampleSDKDelegate(model: appModel)

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        UITestMiniAppHarness.shared.prepareLaunch()
        configureSDK()
        return true
    }

    // MARK: - SDK Configuration

    private func configureSDK() {
        let config = UITestMiniAppHarness.shared.makeSDKConfiguration()
            ?? ExampleSDKBootstrap.makeConfiguration()

        // 3. Configure the SDK
        AliSASDK.shared.configure(sdkConfig: config)

        AliSASDK.shared.saveQueryParam("eruda=1")

        // 4. Apply brand colors
        AliSASDK.shared.updateColorScheme(ExampleSDKBootstrap.colorScheme)

        // 5. Set the delegate
        AliSASDK.shared.setDelegate(sdkDelegate)
    }

    // MARK: - Orientation Lock

    func application(
        _ application: UIApplication,
        supportedInterfaceOrientationsFor window: UIWindow?
    ) -> UIInterfaceOrientationMask {
        AliSASDK.orientationLock
    }

    // MARK: - UISceneSession Lifecycle

    func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(
        _ application: UIApplication,
        didDiscardSceneSessions sceneSessions: Set<UISceneSession>
    ) {}
}

enum ExampleSDKBootstrap {
    static let projectID = "superapp.demo"
    static let subscriptionKey = "DemoSe6d60965fcf4d7d029de4324530eaaa37751cd714d"

    static let colorScheme = AliSASDKColorScheme(
        primaryHex: "#E63946",
        secondaryHex: "#457B9D"
    )

    static func makeConfiguration() -> AliSASDKConfiguration {
        AliSASDKConfiguration(
            environment: .sandbox,
            projectId: projectID,
            subscriptionKey: subscriptionKey
        )
    }
}
