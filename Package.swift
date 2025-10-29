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
        .binaryTarget(
            name: "SwifMetro",
            url: "https://github.com/SwifMetro/SwifMetro-Public-NPM/releases/download/v1.0.12/SwifMetro.xcframework.zip",
            checksum: "72b9daf32fb2ec13c5b739ba21221b6860ba318528f5be8fb1abce804786039a"
        )
    ]
)