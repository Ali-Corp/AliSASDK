// swift-tools-version: 5.9
import PackageDescription

// Binary targets cannot declare dependencies in SwiftPM, so all remote
// packages are pulled in through a thin carrier source target
// (AliSASDKRemoteDependencies) that lives alongside the binaries in the
// product. The consumer gets a single product — "AliSASDK" — and all
// transitive links resolve automatically.
let package = Package(
    name: "AliSASDK",
    defaultLocalization: "en",
    platforms: [.iOS(.v15)],
    products: [
        .library(
            name: "AliSASDK",
            targets: [
                "AliSASDK",
                "MiniApp",
                "MiniAppObjC",
                "AliSASDKRemoteDependencies",
            ]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/twostraws/CodeScanner.git", from: "2.5.2"),
        .package(url: "https://github.com/lm/navigation-stack-backport.git", from: "1.1.0"),
        .package(url: "https://github.com/exyte/MediaPicker.git", from: "2.2.4"),
        .package(url: "https://github.com/TimOliver/TOCropViewController.git", from: "2.8.0"),
        .package(url: "https://github.com/stephencelis/SQLite.swift.git", from: "0.16.0"),
        .package(url: "https://github.com/SwiftyJSON/SwiftyJSON.git", from: "5.0.2"),
        .package(url: "https://github.com/datatheorem/TrustKit.git", from: "2.0.1"),
        .package(url: "https://github.com/weichsel/ZIPFoundation.git", from: "0.9.20"),
    ],
    targets: [
        // ── First-party prebuilt xcframeworks ──────────────────────────────
        .binaryTarget(name: "AliSASDK", path: "iOS/AliSASDK.xcframework"),
        .binaryTarget(name: "MiniApp",  path: "iOS/MiniApp.xcframework"),
        .binaryTarget(name: "MiniAppObjC",  path: "iOS/MiniAppObjC.xcframework"),

        // ── Carrier target: wires remote deps into the product ─────────────
        .target(
            name: "AliSASDKRemoteDependencies",
            dependencies: [
                .product(name: "CodeScanner",            package: "CodeScanner"),
                .product(name: "NavigationStackBackport", package: "navigation-stack-backport"),
                .product(name: "ExyteMediaPicker",       package: "MediaPicker"),
                .product(name: "CropViewController",     package: "TOCropViewController"),
                .product(name: "SQLite",                 package: "SQLite.swift"),
                .product(name: "SwiftyJSON",             package: "SwiftyJSON"),
                .product(name: "TrustKit",               package: "TrustKit"),
                .product(name: "ZIPFoundation",          package: "ZIPFoundation"),
            ],
            path: "Sources/AliSASDKRemoteDependencies"
        ),
    ]
)
