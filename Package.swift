// swift-tools-version: 6.4

import PackageDescription

let package = Package(
    name: "swift-xcode",
    platforms: [
        .macOS(.v27),
        .iOS(.v27),
        .tvOS(.v27),
        .watchOS(.v27),
        .visionOS(.v27),
    ],
    products: [
        .library(name: "Xcode Workspace", targets: ["Xcode Workspace"]),
        .library(name: "Xcode Scheme", targets: ["Xcode Scheme"]),
    ],
    dependencies: [
        .package(
            url: "https://github.com/swift-standards/swift-xcode-standard.git",
            branch: "main"
        ),
        .package(url: "https://github.com/swift-compositions/swift-xml.git", branch: "main"),
        .package(url: "https://github.com/swift-compositions/swift-file-system.git", branch: "main"),
    ],
    targets: [
        .target(
            name: "Xcode Workspace",
            dependencies: [
                .product(name: "Xcode Workspace Standard", package: "swift-xcode-standard"),
                .product(name: "XML", package: "swift-xml"),
                .product(name: "File System", package: "swift-file-system"),
            ]
        ),
        .target(
            name: "Xcode Scheme",
            dependencies: [
                .product(name: "Xcode Scheme Standard", package: "swift-xcode-standard"),
                .product(name: "XML", package: "swift-xml"),
                .product(name: "File System", package: "swift-file-system"),
            ]
        ),
        .testTarget(
            name: "Xcode Workspace Tests",
            dependencies: ["Xcode Workspace"],
            resources: [.copy("Fixtures")]
        ),
        .testTarget(
            name: "Xcode Scheme Tests",
            dependencies: ["Xcode Scheme"]
        ),
    ],
    swiftLanguageModes: [.v6]
)

for target in package.targets where ![.system, .binary, .plugin, .macro].contains(target.type) {
    target.swiftSettings =
        (target.swiftSettings ?? []) + [
            .strictMemorySafety(),
                .enableExperimentalFeature("Lifetimes"),
                .enableUpcomingFeature("ExistentialAny"),
            .enableUpcomingFeature("InferIsolatedConformances"),
            .enableUpcomingFeature("InternalImportsByDefault"),
                .enableUpcomingFeature("MemberImportVisibility"),
            .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
        ]
}
