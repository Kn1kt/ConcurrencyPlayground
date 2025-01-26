// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "ConcurrencyPlayground",
    platforms: [.iOS(.v17)],
    targets: [
        .executableTarget(name: "ConcurrencyPlayground"),
        .testTarget(
            name: "ConcurrencyPlaygroundTests",
            dependencies: ["ConcurrencyPlayground"]
        )
    ],
    swiftLanguageModes: [.v6]
)
