//
//  ALISASDKSwiftUIExampleUITests.swift
//  ALISASDKSwiftUIExampleUITests
//
//  Created by Vu Ho on 6/3/26.
//

import XCTest

final class ALISASDKSwiftUIExampleUITests: XCTestCase {
    private var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
    }

    @MainActor
    func testRootScreenAppearsOnLaunch() throws {
        app.launch()
        XCTAssertTrue(app.navigationBars["AliSASDK Example"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["Login (Sample User)"].waitForExistence(timeout: 5))
    }

    @MainActor
    func testLaunchPerformance() throws {
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            app.launch()
        }
    }
}
