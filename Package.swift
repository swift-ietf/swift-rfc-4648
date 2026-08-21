// swift-tools-version: 6.4
import PackageDescription

let package = Package(
    name: "swift-rfc-4648",
    platforms: [
        .macOS(.v27),
        .iOS(.v27),
        .tvOS(.v27),
        .watchOS(.v27),
        .visionOS(.v27),
    ],
    products: [
        .library(name: "RFC 4648", targets: ["RFC 4648"]),
        .library(name: "RFC 4648 Foundation", targets: ["RFC 4648 Foundation"]),
    ],
    dependencies: [
        .package(
            url: "https://github.com/swift-primitives/swift-standard-library-extensions.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-primitives/swift-binary-primitives.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-primitives/swift-ascii-primitives.git",
            branch: "main"
        ),
    ],
    targets: [
        .target(
            name: "RFC 4648",
            dependencies: [
                .product(
                    name: "Standard Library Extensions",
                    package: "swift-standard-library-extensions"
                ),
                .product(name: "Binary Primitives", package: "swift-binary-primitives"),
                .product(name: "ASCII Primitives", package: "swift-ascii-primitives"),
            ],
            swiftSettings: [
                .enableExperimentalFeature("Lifetimes")
            ]
        ),
        .target(
            name: "RFC 4648 Foundation",
            dependencies: [
                "RFC 4648",
                .product(
                    name: "Standard Library Extensions",
                    package: "swift-standard-library-extensions"
                ),
            ]
        ),
        .testTarget(
            name: "RFC 4648 Tests",
            dependencies: [
                "RFC 4648"
            ]
        ),
        .testTarget(
            name: "RFC 4648 Foundation Tests",
            dependencies: [
                "RFC 4648 Foundation"
            ]
        ),
    ]
)

for target in package.targets where ![.system, .binary, .plugin, .macro].contains(target.type) {
    let ecosystem: [SwiftSetting] = [
        .strictMemorySafety(),
        .enableUpcomingFeature("ExistentialAny"),
        .enableUpcomingFeature("InternalImportsByDefault"),
        .enableUpcomingFeature("MemberImportVisibility"),
        .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
        .enableExperimentalFeature("Lifetimes"),
    ]

    let package: [SwiftSetting] = []

    target.swiftSettings = (target.swiftSettings ?? []) + ecosystem + package
}
