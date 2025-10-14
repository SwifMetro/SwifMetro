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
            url: "https://github.com/SwifMetro/SwifMetro/releases/download/v1.0.10/SwifMetro.xcframework.zip",
            checksum: "1be2a30797f9370fdac5789d5e5266b9c872a3f65780b07466a51cd454d95737"
        )
    ]
)
