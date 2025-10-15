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
            url: "https://github.com/SwifMetro/SwifMetro/releases/download/v1.0.11/SwifMetro.xcframework.zip",
            checksum: "4310bd5857f140bff450c8cbe1decf9d9f47f9cc1e714e236157fced7e6cf0b6"
        )
    ]
)
