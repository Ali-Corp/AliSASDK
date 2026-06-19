Pod::Spec.new do |s|
  s.name             = 'AliSASDK'
  s.version          = '1.0.0'
  s.summary          = 'iOS SDK for integrating MiniApp functionality into ALI super-applications.'
  s.description      = <<~DESC
    AliSASDK provides a complete SwiftUI-based MiniApp runtime — including view rendering,
    navigation, permissions, QR scanning, media picking, and lifecycle management — behind a
    clean public API that isolates the host app from the underlying MiniApp SDK.
  DESC

  s.homepage         = 'https://github.com/Ali-Corp/AliSASDK'
  s.license          = { type: 'Proprietary', file: 'LICENSE.md' }
  s.author           = { 'ALI Corp' => 'dev@ali.vn' }
  s.source           = { git: 'https://github.com/Ali-Corp/AliSASDK.git', tag: s.version.to_s }

  s.platform         = :ios, '15.0'
  s.swift_version    = '5.9'

  # Vendored xcframeworks — includes CodeScanner + NavigationStackBackport because
  # those libraries are SPM-only (no CocoaPods podspec exists for them).
  s.vendored_frameworks = [
    'iOS/AliSASDK.xcframework',
    'iOS/AliSASDKCore.xcframework',
    'iOS/MiniApp.xcframework',
    'iOS/MiniAppObjC.xcframework',
    'iOS/CodeScanner.xcframework',
    'iOS/NavigationStackBackport.xcframework',
  ]

  # All vendored frameworks are static archives.
  s.static_framework = true

  # Remote CocoaPods dependencies — the remaining 6 third-party libraries
  # that ship both a podspec and a SwiftPM package.
  s.dependency 'ExyteMediaPicker',  '~> 2.2'
  s.dependency 'CropViewController','~> 2.8'
  s.dependency 'SQLite.swift',      '~> 0.16'
  s.dependency 'SwiftyJSON',        '~> 5.0'
  s.dependency 'TrustKit',          '~> 2.0'
  s.dependency 'ZIPFoundation',     '~> 0.9'
end
