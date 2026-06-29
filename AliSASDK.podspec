Pod::Spec.new do |s|
  s.name             = 'AliSASDK'
  s.version          = '1.0.2'
  s.summary          = 'iOS SDK for integrating MiniApp functionality into ALI super-applications.'
  s.description      = <<~DESC
    AliSASDK provides a complete SwiftUI-based MiniApp runtime — including view rendering,
    navigation, permissions, QR scanning, media picking, and lifecycle management — behind a
    clean public API that isolates the host app from the underlying MiniApp SDK.
  DESC

  s.homepage         = 'https://github.com/Ali-Corp/AliSASDK'
  s.license          = { type: 'Proprietary', file: 'LICENSE.md' }
  s.author           = { 'ALI Corp' => 'developer@ali.vn' }
  s.source           = { git: 'https://github.com/Ali-Corp/AliSASDK.git', tag: s.version.to_s }

  s.platform         = :ios, '15.0'
  s.swift_version    = '5.9'

  # Vendored xcframeworks — includes CodeScanner + NavigationStackBackport because
  # those libraries are SPM-only (no CocoaPods podspec exists for them).
  # MiniApp + MiniAppObjC now come from the remote AliMiniAppSDK pod.
  s.vendored_frameworks = [
    'iOS/AliSASDK.xcframework',
    'iOS/CodeScanner.xcframework',
    'iOS/NavigationStackBackport.xcframework',
  ]

  s.resources = [
    'iOS/AliSASDK.xcframework/ios-arm64/AliSASDK.framework/AliSASDK_AliSASDK.bundle',
  ]

  # All vendored frameworks are static archives.
  s.static_framework = false

  # MiniApp runtime — ships the MiniApp/MiniAppObjC xcframeworks and their
  # third-party dependencies (ZIPFoundation, TrustKit, SQLite.swift, SwiftyJSON).
  s.dependency 'AliMiniAppSDK',     '5.10.4'

  # Remote CocoaPods dependencies used by the AliSASDK core framework.
  s.dependency 'ExyteMediaPicker',  '~> 2.2'
  s.dependency 'CropViewController','~> 2.8'
end
