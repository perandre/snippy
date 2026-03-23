// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "Snippy",
    platforms: [.macOS(.v14)],
    targets: [
        .executableTarget(
            name: "Snippy",
            path: "Sources",
            swiftSettings: [.swiftLanguageMode(.v5)]
        )
    ]
)
