//
//  UITestMiniAppHarness.swift
//  ALISASDKUIKitExample
//
//  Deterministic backend fixture for UIKit example UI tests.
//

import Foundation
import AliSASDK

struct UITestMiniAppHarness {
    static let shared = UITestMiniAppHarness(environment: ProcessInfo.processInfo.environment)

    static let scenarioKey = "ALI_UI_TEST_SCENARIO"
    static let phaseKey = "ALI_UI_TEST_PHASE"

    static let supportedScenario = "cached_update_accept_refresh"
    static let fixtureAppId = "uitest.cached-update-refresh"
    static let fixtureButtonIdentifier = "example.miniapp.\(fixtureAppId)"
    static let fixtureHost = "miniapp-uitest.local"
    static let baseURL = "https://\(fixtureHost)/sdk-api/"
    static let projectId = "superapp.demo"
    static let subscriptionKey = "uitest-subscription-key"

    let scenario: String?
    let phase: Phase?

    var isEnabled: Bool {
        scenario == Self.supportedScenario && phase != nil
    }

    init(environment: [String: String]) {
        scenario = environment[Self.scenarioKey]
        phase = environment[Self.phaseKey].flatMap(Phase.init(rawValue:))
    }

    func prepareLaunch() {
        guard isEnabled else { return }

        URLProtocol.registerClass(FixtureURLProtocol.self)

        if phase == .seedV1 {
            clearPersistedState()
        }
    }

    func makeSDKConfiguration() -> AliSASDKConfiguration? {
        guard isEnabled else { return nil }

        return AliSASDKConfiguration(
            environment: .sandbox,
            projectId: Self.projectId,
            subscriptionKey: Self.subscriptionKey,
            isPreviewMode: false
        )
    }

    fileprivate func latestMiniAppInfo() -> MiniAppInfo {
        Self.miniAppInfo(versionId: phase == .upgradeToV2 ? "v2" : "v1")
    }

    private func clearPersistedState() {
        let cachesDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        let miniAppDirectory = cachesDirectory.appendingPathComponent("MiniApp/\(Self.fixtureAppId)", isDirectory: true)
        try? FileManager.default.removeItem(at: miniAppDirectory)

        let downloadStatusDefaults = UserDefaults(suiteName: "vn.ali.mobile.miniapp")
        downloadStatusDefaults?.removeObject(forKey: Self.fixtureAppId)
        downloadStatusDefaults?.removeObject(forKey: "\(Self.fixtureAppId)/v1")
        downloadStatusDefaults?.removeObject(forKey: "\(Self.fixtureAppId)/v2")

        let miniAppInfoDefaults = UserDefaults(suiteName: "vn.ali.mobile.miniapp.MiniAppDemo.MiniAppInfo")
        miniAppInfoDefaults?.removeObject(forKey: Self.fixtureAppId)
    }
}

extension UITestMiniAppHarness {
    enum Phase: String {
        case seedV1 = "seed_v1"
        case upgradeToV2 = "upgrade_to_v2"
    }

    static func miniAppInfo(versionId: String) -> MiniAppInfo {
        let versionTag = versionId == "v2" ? "2.0.0" : "1.0.0"

        return MiniAppInfo(
            id: fixtureAppId,
            displayName: "UI Test Cached Update MiniApp",
            icon: URL(string: "\(baseURL)\(fixtureAppId)/\(versionId)/icon.png")!,
            version: Version(versionTag: versionTag, versionId: versionId),
            promotionalImageUrl: nil,
            promotionalText: nil
        )
    }
}

private final class FixtureURLProtocol: URLProtocol {
    override class func canInit(with request: URLRequest) -> Bool {
        guard UITestMiniAppHarness.shared.isEnabled else { return false }
        return request.url?.host == UITestMiniAppHarness.fixtureHost
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }

    override func startLoading() {
        guard let url = request.url,
              let response = response(for: url) else {
            client?.urlProtocol(self, didFailWithError: URLError(.resourceUnavailable))
            return
        }

        client?.urlProtocol(self, didReceive: response.response, cacheStoragePolicy: .notAllowed)
        client?.urlProtocol(self, didLoad: response.body)
        client?.urlProtocolDidFinishLoading(self)
    }

    override func stopLoading() {}
}

private extension FixtureURLProtocol {
    typealias StubbedResponse = (response: HTTPURLResponse, body: Data)

    func response(for url: URL) -> StubbedResponse? {
        let harness = UITestMiniAppHarness.shared
        let path = url.path

        if path.hasSuffix("/host/\(UITestMiniAppHarness.projectId)/miniapps") {
            return miniAppInfoResponse(for: url, latestInfo: harness.latestMiniAppInfo())
        }

        if path.contains("/host/\(UITestMiniAppHarness.projectId)/miniapp/\(UITestMiniAppHarness.fixtureAppId)/version/"),
           path.hasSuffix("/manifest"),
           let versionId = versionId(from: path) {
            return jsonResponse(
                url: url,
                object: [
                    "manifest": [
                        "\(UITestMiniAppHarness.baseURL)\(UITestMiniAppHarness.fixtureAppId)/\(versionId)/index.html"
                    ]
                ]
            )
        }

        if path.contains("/host/\(UITestMiniAppHarness.projectId)/miniapp/\(UITestMiniAppHarness.fixtureAppId)/version/"),
           path.hasSuffix("/metadata"),
           let versionId = versionId(from: path) {
            return jsonResponse(
                url: url,
                object: [
                    "bundleManifest": [
                        "reqPermissions": [],
                        "optPermissions": [],
                        "customMetaData": [
                            "uiTestVersion": versionId
                        ],
                        "accessTokenPermissions": []
                    ]
                ]
            )
        }

        if path.hasSuffix("/\(UITestMiniAppHarness.fixtureAppId)/v1/index.html") {
            return htmlResponse(url: url, body: fixtureHTML(versionLabel: "UITEST MINIAPP V1"))
        }

        if path.hasSuffix("/\(UITestMiniAppHarness.fixtureAppId)/v2/index.html") {
            return htmlResponse(url: url, body: fixtureHTML(versionLabel: "UITEST MINIAPP V2"))
        }

        if path.hasSuffix("/icon.png") {
            return dataResponse(url: url, mimeType: "image/png", body: Data())
        }

        return nil
    }

    func miniAppInfoResponse(for url: URL, latestInfo: MiniAppInfo) -> StubbedResponse? {
        let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        let requestedMiniAppId = components?.queryItems?.first(where: { $0.name == "miniAppId" })?.value

        if let requestedMiniAppId, requestedMiniAppId != UITestMiniAppHarness.fixtureAppId {
            return jsonResponse(url: url, object: [])
        }

        let data = try? JSONEncoder().encode([latestInfo])
        guard let body = data else { return nil }
        return dataResponse(url: url, mimeType: "application/json", body: body)
    }

    func htmlResponse(url: URL, body: String) -> StubbedResponse? {
        guard let data = body.data(using: .utf8) else { return nil }
        return dataResponse(url: url, mimeType: "text/html", body: data)
    }

    func jsonResponse(url: URL, object: Any) -> StubbedResponse? {
        guard let data = try? JSONSerialization.data(withJSONObject: object, options: []) else { return nil }
        return dataResponse(url: url, mimeType: "application/json", body: data)
    }

    func dataResponse(url: URL, mimeType: String, body: Data) -> StubbedResponse? {
        guard let response = HTTPURLResponse(
            url: url,
            statusCode: 200,
            httpVersion: nil,
            headerFields: ["Content-Type": mimeType]
        ) else {
            return nil
        }

        return (response, body)
    }

    func versionId(from path: String) -> String? {
        let marker = "/version/"
        guard let versionRange = path.range(of: marker) else { return nil }
        let suffix = path[versionRange.upperBound...]
        return suffix.split(separator: "/").first.map(String.init)
    }

    func fixtureHTML(versionLabel: String) -> String {
        """
        <!doctype html>
        <html lang="en">
        <head>
          <meta charset="utf-8" />
          <meta name="viewport" content="width=device-width, initial-scale=1" />
          <title>\(versionLabel)</title>
          <style>
            body {
              margin: 0;
              min-height: 100vh;
              display: grid;
              place-items: center;
              background: linear-gradient(160deg, #f5f1e8 0%, #d9e7f2 100%);
              color: #15243a;
              font-family: -apple-system, BlinkMacSystemFont, sans-serif;
            }
            main {
              padding: 32px;
              border-radius: 24px;
              background: rgba(255, 255, 255, 0.88);
              box-shadow: 0 20px 60px rgba(21, 36, 58, 0.18);
              text-align: center;
            }
            h1 {
              margin: 0 0 12px;
              font-size: 30px;
            }
            p {
              margin: 0;
              font-size: 17px;
            }
          </style>
        </head>
        <body>
          <main>
            <h1>\(versionLabel)</h1>
            <p>Deterministic cached update fixture</p>
          </main>
        </body>
        </html>
        """
    }
}
