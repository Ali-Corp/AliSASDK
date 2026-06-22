//
//  SampleSDKDelegate.swift
//  ALISASDKUIKitExample
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
        print("[SampleSDKDelegate] SDK requested login — present your auth flow here")
        model.recordLoginRequest(source: "sdk")
    }

    // MARK: - Optional

    func aliSASDKOpenURL(_ url: URL) {
        print("[SampleSDKDelegate] Open URL: \(url)")
        model.recordOpenedURL(url.absoluteString)
    }

    func aliSASDKTrackEvent(name: String, params: [String: String]?) {
        print("[SampleSDKDelegate] Track event: \(name), params: \(params ?? [:])")
        model.recordTrackEvent(name: name, params: params)
    }

    func aliSASDKHandleJsonFromMiniApp(json: String, miniAppId: String) {
        print("[SampleSDKDelegate] Received JSON from \(miniAppId): \(json)")
        model.recordReceivedJSON(json, miniAppId: miniAppId)
    }

    func aliSASDKDidOpenMiniApp(id: String) {
        print("[SampleSDKDelegate] MiniApp opened: \(id)")
        model.recordLifecycleEvent("opened:\(id)")
    }

    func aliSASDKDidCloseMiniApp(id: String) {
        print("[SampleSDKDelegate] MiniApp closed: \(id)")
        model.recordLifecycleEvent("closed:\(id)")
    }
}
