// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "SwifMetro",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_15)
    ],
    products: [
        .library(
            name: "SwifMetro",
            targets: ["SwifMetro"]
        )
    ],
    dependencies: [],
    targets: [
        .target(
            name: "SwifMetro",
            dependencies: [],
            path: "Sources/SwifMetro"
        )
    ]
)
