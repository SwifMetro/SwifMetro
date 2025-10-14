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
            url: "https://github.com/SwifMetro/SwifMetro/releases/download/v1.0.5/SwifMetro.xcframework.zip",
            checksum: "40b40e51544eaa3356a5f6cb43b16d12283323e14028283469422897f3f18598"
        )
    ]
)
