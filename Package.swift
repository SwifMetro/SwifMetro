// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "SwifMetro",
    platforms: [
        .iOS(.v14)
    ],
    products: [
        .library(
            name: "SwifMetro",
            targets: ["SwifMetro"])
    ],
    targets: [
        .binaryTarget(
            name: "SwifMetro",
            url: "https://github.com/SwifMetro/SwifMetro/releases/download/v1.0.3/SwifMetro.xcframework.zip",
            checksum: "4cb69009c801225fb7c43f0ff56001bcb63f5ccf4daabe0a21a91d1d65dea579"
        )
    ]
)
