// swift-tools-version:5.0
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
    targets: [
        .target(
            name: "CSPA",
            dependencies: []),
        .target(
            name: "SolarPosition",
            dependencies: ["CSPA"])
        ]
)
