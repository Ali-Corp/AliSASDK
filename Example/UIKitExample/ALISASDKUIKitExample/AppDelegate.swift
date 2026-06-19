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

    /// The delegate must be retained for the SDK's lifetime.
    let sdkDelegate = SampleSDKDelegate()

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
        // 1. Define brand colors
        let colorScheme = AliSASDKColorScheme(
            primaryHex: "#E63946",
            secondaryHex: "#457B9D"
        )

        // 2. Build configuration with sample values
        let config = UITestMiniAppHarness.shared.makeSDKConfiguration()
            ?? AliSASDKConfiguration(
                environment: .sandbox,
                projectId: "superapp.demo",
                subscriptionKey: "DemoSe6d60965fcf4d7d029de4324530eaaa37751cd714d",
                isPreviewMode: true
            )

        // 3. Configure the SDK
        AliSASDK.shared.configure(sdkConfig: config)

        // 4. Apply brand colors
        AliSASDK.shared.updateColorScheme(colorScheme)

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
