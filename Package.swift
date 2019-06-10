// swift-tools-version:5.1
import PackageDescription

let package = Package(
    name: "SolarPosition",
    platforms: [
        .iOS(.v9), .macOS(.v10_13), .tvOS(.v11)
    ],
    products: [
        .library(
            name: "CSPA",
            targets: ["CSPA"]),
        .library(
            name: "SolarPosition",
            targets: ["SolarPosition"]),
        ],
    dependencies: [
        // .package(url: "https://github.com/wolfmcnally/WolfCore", .branch("Swift-5.1")),
        // .package(url: "https://github.com/wolfmcnally/WolfCore", from: "4.0.0"),
    ],
    targets: [
        .target(
            name: "CSPA",
            dependencies: []),
        .target(
            name: "SolarPosition",
            dependencies: ["CSPA"])
        ]
)
