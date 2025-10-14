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
            url: "https://github.com/SwifMetro/SwifMetro/releases/download/v1.0.7/SwifMetro.xcframework.zip",
            checksum: "d78755966b511d87cf6ceffbfeb3dfc9b626823fe875c0300c060b8f9db47c47"
        )
    ]
)
