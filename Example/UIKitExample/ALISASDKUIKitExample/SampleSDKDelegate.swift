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

    // MARK: - Required

    func aliSASDKRequestLogin() {
        print("[SampleSDKDelegate] SDK requested login — present your auth flow here")
    }

    // MARK: - Optional

    func aliSASDKOpenURL(_ url: URL) {
        print("[SampleSDKDelegate] Open URL: \(url)")
    }

    func aliSASDKTrackEvent(name: String, params: [String: String]?) {
        print("[SampleSDKDelegate] Track event: \(name), params: \(params ?? [:])")
    }

    func aliSASDKHandleJsonFromMiniApp(json: String, miniAppId: String) {
        print("[SampleSDKDelegate] Received JSON from \(miniAppId): \(json)")
    }

    func aliSASDKDidOpenMiniApp(id: String) {
        print("[SampleSDKDelegate] MiniApp opened: \(id)")
    }

    func aliSASDKDidCloseMiniApp(id: String) {
        print("[SampleSDKDelegate] MiniApp closed: \(id)")
    }
}
