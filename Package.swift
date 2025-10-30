// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "SwifMetro",
    platforms: [
        .iOS(.v14),
        .macOS(.v11),
        .tvOS(.v14),
        .watchOS(.v7)
    ],
    products: [
        .library(
            name: "SwifMetro",
            targets: ["SwifMetro"]
        ),
    ],
    targets: [
        .binaryTarget(
            name: "SwifMetro",
            url: "https://github.com/SwifMetro/SwifMetro/releases/download/v1.0.20/SwifMetro.xcframework.zip",
            checksum: "e228339629771b73c15b31341d9be33f74fb2f633fa42840284e7e0a7816bfe0"
        )
    ]
)