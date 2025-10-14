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
            url: "https://github.com/SwifMetro/SwifMetro/releases/download/v1.0.6/SwifMetro.xcframework.zip",
            checksum: "e356e1c4c335b271fa89fc8d08e9ad010a0f013d4553663032d1ca26910fe486"
        )
    ]
)
