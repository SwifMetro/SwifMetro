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
            url: "https://github.com/SwifMetro/SwifMetro/releases/download/v1.0.25/SwifMetro.xcframework.zip",
            checksum: "c29dd21692f347b83528fa18e24d9a28dab3d1d7ce3e86614f3a3e4f9a2cb646"
        )
    ]
)