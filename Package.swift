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
        .target(
            name: "SwifMetro",
            path: "Sources",
            exclude: ["Info.plist"],
            resources: [
                .copy("Resources")
            ]
        ),
        .testTarget(
            name: "SwifMetroTests",
            dependencies: ["SwifMetro"],
            path: "Tests"
        ),
    ]
)