//
//  ALISASDKUIKitExampleUITests.swift
//  ALISASDKUIKitExampleUITests
//
//  Created by Vu Ho on 6/3/26.
//

import XCTest

final class ALISASDKUIKitExampleUITests: XCTestCase {
    private let fixtureButtonIdentifier = "example.miniapp.uitest.cached-update-refresh"
    private let updateDialogIdentifier = "miniapp.demo.sdk.dialog.container"
    private let updatePrimaryButtonIdentifier = "miniapp.demo.sdk.dialog.primary"
    private let scenarioKey = "ALI_UI_TEST_SCENARIO"
    private let phaseKey = "ALI_UI_TEST_PHASE"
    private let scenarioValue = "cached_update_accept_refresh"

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    @MainActor
    func testOpenMiniAppWithCachedVersionShowsUpdatePopupAndRefreshesAfterAccept() throws {
        let seedApp = makeApp(phase: "seed_v1")
        seedApp.launch()

        let seedButton = seedApp.buttons[fixtureButtonIdentifier]
        XCTAssertTrue(seedButton.waitForExistence(timeout: 10))
        seedButton.tap()

        XCTAssertTrue(seedApp.staticTexts["UITEST MINIAPP V1"].waitForExistence(timeout: 20))
        seedApp.terminate()

        let upgradeApp = makeApp(phase: "upgrade_to_v2")
        upgradeApp.launch()

        let upgradeButton = upgradeApp.buttons[fixtureButtonIdentifier]
        XCTAssertTrue(upgradeButton.waitForExistence(timeout: 10))
        upgradeButton.tap()

        let updateDialog = upgradeApp.otherElements[updateDialogIdentifier]
        XCTAssertTrue(updateDialog.waitForExistence(timeout: 20))

        let updateButton = upgradeApp.buttons[updatePrimaryButtonIdentifier]
        XCTAssertTrue(updateButton.waitForExistence(timeout: 10))
        updateButton.tap()

        XCTAssertTrue(upgradeApp.staticTexts["UITEST MINIAPP V2"].waitForExistence(timeout: 20))
        XCTAssertFalse(updateDialog.waitForExistence(timeout: 1))
    }

    @MainActor
    func testLaunchPerformance() throws {
        // This measures how long it takes to launch your application.
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }
}

private extension ALISASDKUIKitExampleUITests {
    func makeApp(phase: String) -> XCUIApplication {
        let app = XCUIApplication()
        app.launchEnvironment[scenarioKey] = scenarioValue
        app.launchEnvironment[phaseKey] = phase
        return app
    }
}
