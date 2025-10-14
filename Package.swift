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
            url: "https://github.com/SwifMetro/SwifMetro/releases/download/v1.0.9/SwifMetro.xcframework.zip",
            checksum: "14c24c8fd4a30d505f19ef379ea64e3412c553dc484171b1357f00136c229dac"
        )
    ]
)
