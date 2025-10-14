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
            url: "https://github.com/SwifMetro/SwifMetro/releases/download/v1.0.8/SwifMetro.xcframework.zip",
            checksum: "299eec9a7a751cce005f832a5f994d96d1056828a87f2d89f9f329fb6709c0b8"
        )
    ]
)
