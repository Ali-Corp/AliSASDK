// swift-tools-version: 5.9
import PackageDescription

// Binary targets cannot declare dependencies in SwiftPM, so all remote
// packages are pulled in through a thin carrier source target
// (AliSASDKRemoteDependencies) that lives alongside the binaries in the
// product. The MiniApp binaries and their dependencies now come from the
// remote AliMiniAppSDK package. The consumer gets a single product —
// "AliSASDK" — and all transitive links resolve automatically.
let package = Package(
    name: "AliSASDK",
    defaultLocalization: "en",
    platforms: [.iOS(.v15)],
    products: [
        .library(
            name: "AliSASDK",
            targets: [
                "AliSASDK",
                "AliSASDKRemoteDependencies",
            ]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/Ali-Corp/AliMiniAppSDK.git", branch: "dev"),
        .package(url: "https://github.com/twostraws/CodeScanner.git", from: "2.5.2"),
        .package(url: "https://github.com/lm/navigation-stack-backport.git", from: "1.1.0"),
        .package(url: "https://github.com/exyte/MediaPicker.git", from: "2.2.4"),
        .package(url: "https://github.com/TimOliver/TOCropViewController.git", from: "2.8.0"),
    ],
    targets: [
        // ── First-party prebuilt xcframework ───────────────────────────────
        .binaryTarget(name: "AliSASDK", path: "iOS/AliSASDK.xcframework"),

        // ── Carrier target: wires remote deps into the product ─────────────
        // Also ships AliSASDK_AliSASDK.bundle so Bundle.module in the binary
        // xcframework resolves correctly at runtime via Bundle.main.resourceURL.
        .target(
            name: "AliSASDKRemoteDependencies",
            dependencies: [
                .product(name: "AliMiniAppSDK",          package: "AliMiniAppSDK"),
                .product(name: "CodeScanner",            package: "CodeScanner"),
                .product(name: "NavigationStackBackport", package: "navigation-stack-backport"),
                .product(name: "ExyteMediaPicker",       package: "MediaPicker"),
                .product(name: "CropViewController",     package: "TOCropViewController"),
            ],
            path: "Sources/AliSASDKRemoteDependencies",
            resources: [.process("resources")]
        ),
    ]
)
