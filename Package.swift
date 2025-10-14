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
            url: "https://github.com/SwifMetro/SwifMetro/releases/download/v1.0.4/SwifMetro.xcframework.zip",
            checksum: "66b3e9cc8291a4757a3a5f2cad60c02fd550212972d861dbaa331e5c1ddfcdf8"
        )
    ]
)
