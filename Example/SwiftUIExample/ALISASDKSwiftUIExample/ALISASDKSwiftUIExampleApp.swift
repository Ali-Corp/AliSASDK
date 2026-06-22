//
//  ALISASDKSwiftUIExampleApp.swift
//  ALISASDKSwiftUIExample
//
//  Demonstrates AliSASDK configuration at app launch.
//

import SwiftUI
import AliSASDK

@main
struct ALISASDKSwiftUIExampleApp: App {

    /// The delegate must be retained for the SDK's lifetime.
    private let appModel: ExampleAppModel
    private let sdkDelegate: SampleSDKDelegate

    init() {
        let appModel = ExampleAppModel()
        let sdkDelegate = SampleSDKDelegate(model: appModel)
        self.appModel = appModel
        self.sdkDelegate = sdkDelegate

        // 3. Configure the SDK
        AliSASDK.shared.configure(sdkConfig: ExampleSDKBootstrap.makeConfiguration())

        AliSASDK.shared.saveQueryParam("eruda=1")

        // 4. Apply brand colors
        AliSASDK.shared.updateColorScheme(ExampleSDKBootstrap.colorScheme)

        // 5. Set the delegate
        AliSASDK.shared.setDelegate(sdkDelegate)
    }

    var body: some Scene {
        WindowGroup {
            ContentView(model: appModel)
        }
    }
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
