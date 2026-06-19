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
        app.launchArguments.append("--ui-testing")
    }

    @MainActor
    func testFixtureInjectsUpdatedLanguageIntoBridge() throws {
        app.launch()

        let englishButton = app.segmentedControls.buttons["EN"]
        XCTAssertTrue(englishButton.waitForExistence(timeout: 5))
        englishButton.tap()

        openFixture()

        let readLocaleButton = app.webViews.buttons["Read Host Locale"]
        XCTAssertTrue(readLocaleButton.waitForExistence(timeout: 10))
        readLocaleButton.tap()

        XCTAssertTrue(app.webViews.staticTexts["locale:en"].waitForExistence(timeout: 5))
    }

    @MainActor
    func testFixtureBridgeCallbacksUpdateHarnessState() throws {
        app.launch()

        openFixture()

        let configureHeaderButton = app.webViews.buttons["Configure Native Header"]
        XCTAssertTrue(configureHeaderButton.waitForExistence(timeout: 10))
        configureHeaderButton.tap()
        assertValue(identifier: "example.e2e.harness.navTitle", contains: "Configured Harness")

        let sendJSONButton = app.webViews.buttons["Send JSON To Host"]
        XCTAssertTrue(sendJSONButton.waitForExistence(timeout: 5))
        sendJSONButton.tap()
        assertValue(
            identifier: "example.e2e.harness.lastJSON",
            contains: #"fixture-a:{"type":"fixture-ping","source":"fixture-a"}"#
        )

        let openWebViewButton = app.webViews.buttons["Open WebView"]
        XCTAssertTrue(openWebViewButton.waitForExistence(timeout: 5))
        openWebViewButton.tap()
        assertValue(
            identifier: "example.e2e.harness.lastURL",
            contains: "https://example.com/e2e?fixture=fixture-a"
        )
    }

    @MainActor
    func testFixtureCanOpenNestedMiniAppAndCloseIt() throws {
        app.launch()

        openFixture()

        let openNestedButton = app.webViews.buttons["Open Nested Fixture"]
        XCTAssertTrue(openNestedButton.waitForExistence(timeout: 10))
        openNestedButton.tap()

        XCTAssertTrue(app.webViews.staticTexts["Fixture B"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.webViews.staticTexts["query-source:fixture-a"].waitForExistence(timeout: 5))
        assertValue(identifier: "example.e2e.harness.stackDepth", contains: "stackDepth:2")

        let closeButton = app.webViews.buttons["Close Without Confirmation"]
        XCTAssertTrue(closeButton.waitForExistence(timeout: 5))
        closeButton.tap()

        XCTAssertTrue(app.webViews.staticTexts["Fixture A"].waitForExistence(timeout: 10))
        assertValue(identifier: "example.e2e.harness.stackDepth", contains: "stackDepth:1")
    }

    @MainActor
    func testLoginRequiredDismissesHarnessAndRequestsHostLogin() throws {
        app.launch()

        openFixture()

        let requireLoginButton = app.webViews.buttons["Require Login"]
        XCTAssertTrue(requireLoginButton.waitForExistence(timeout: 10))
        requireLoginButton.tap()

        let loginAlert = app.alerts["Login Required"]
        XCTAssertTrue(loginAlert.waitForExistence(timeout: 5))
        loginAlert.buttons["Login"].tap()

        XCTAssertTrue(app.buttons["Open Deterministic Fixture"].waitForExistence(timeout: 5))
        assertValue(identifier: "example.e2e.status.loginRequests", contains: "1")
        assertValue(identifier: "example.e2e.status.lastClose", contains: "login-requested:fixture-a")
    }

    @MainActor
    func testCloseWithConfirmationDismissesFixture() throws {
        app.launch()

        openFixture()

        let closeButton = app.webViews.buttons["Close With Confirmation"]
        XCTAssertTrue(closeButton.waitForExistence(timeout: 10))
        closeButton.tap()

        let closeAlert = app.alerts["Close Fixture"]
        XCTAssertTrue(closeAlert.waitForExistence(timeout: 5))
        closeAlert.buttons["OK"].tap()

        XCTAssertTrue(app.buttons["Open Deterministic Fixture"].waitForExistence(timeout: 5))
        assertValue(identifier: "example.e2e.status.lastClose", contains: "confirm-close:fixture-a")
    }

    @MainActor
    func testLaunchPerformance() throws {
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            app.launch()
        }
    }

    private func openFixture() {
        let openFixtureButton = app.buttons["Open Deterministic Fixture"]
        XCTAssertTrue(openFixtureButton.waitForExistence(timeout: 5))
        openFixtureButton.tap()

        XCTAssertTrue(app.webViews.staticTexts["bridge-ready"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.webViews.staticTexts["Fixture A"].waitForExistence(timeout: 5))
    }

    private func assertValue(identifier: String, contains expectedText: String, timeout: TimeInterval = 5) {
        let value = app.staticTexts[identifier]
        scrollToElementIfNeeded(value, timeout: timeout)
        XCTAssertTrue(value.waitForExistence(timeout: timeout))
        XCTAssertTrue(
            value.label.contains(expectedText),
            "Expected \(identifier) to contain '\(expectedText)', got '\(value.label)'"
        )
    }

    private func scrollToElementIfNeeded(_ element: XCUIElement, timeout: TimeInterval) {
        guard !element.waitForExistence(timeout: timeout) else { return }

        let table = app.tables.firstMatch
        guard table.waitForExistence(timeout: timeout) else { return }

        for _ in 0..<4 where !element.exists {
            table.swipeUp()
        }
    }
}
