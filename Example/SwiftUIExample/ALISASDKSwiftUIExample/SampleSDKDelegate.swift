//
//  SampleSDKDelegate.swift
//  ALISASDKSwiftUIExample
//
//  A minimal AliSASDKDelegate implementation demonstrating required and optional callbacks.
//

import Foundation
import AliSASDK

/// Sample delegate that handles SDK callbacks.
/// In production, connect these to your real login flow, analytics, etc.
@MainActor
final class SampleSDKDelegate: AliSASDKDelegate {
    private let model: ExampleAppModel

    init(model: ExampleAppModel) {
        self.model = model
    }

    // MARK: - Required

    func aliSASDKRequestLogin() {
        model.recordLoginRequest(source: "sdk")
        print("[SampleSDKDelegate] SDK requested login — present your auth flow here")
    }

    // MARK: - Optional

    func aliSASDKOpenURL(_ url: URL) {
        model.recordOpenedURL(url.absoluteString)
        print("[SampleSDKDelegate] Open URL: \(url)")
    }

    func aliSASDKTrackEvent(name: String, params: [String: String]?) {
        model.recordTrackEvent(name: name, params: params)
        print("[SampleSDKDelegate] Track event: \(name), params: \(params ?? [:])")
    }

    func aliSASDKHandleJsonFromMiniApp(json: String, miniAppId: String) {
        model.recordReceivedJSON(json, miniAppId: miniAppId)
        print("[SampleSDKDelegate] Received JSON from \(miniAppId): \(json)")
    }

    func aliSASDKDidOpenMiniApp(id: String) {
        model.recordLifecycleEvent("opened:\(id)")
        print("[SampleSDKDelegate] MiniApp opened: \(id)")
    }

    func aliSASDKDidCloseMiniApp(id: String) {
        model.recordLifecycleEvent("closed:\(id)")
        print("[SampleSDKDelegate] MiniApp closed: \(id)")
    }
}
