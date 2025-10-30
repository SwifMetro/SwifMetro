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
            url: "https://github.com/SwifMetro/SwifMetro/releases/download/v1.0.23/SwifMetro.xcframework.zip",
            checksum: "9b659ec4cd60b2eb944deddcd54f9c10d9e65fa6203e4634010dbd039e0c341d"
        )
    ]
)