// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "DigiTributeCore",
    platforms: [
        .iOS(.v16),
        .macOS(.v13)
    ],
    products: [
        .library(
            name: "DigiTributeCore",
            targets: ["DigiTributeCore"]
        ),
        .executable(
            name: "DigiTributeApp",
            targets: ["DigiTributeApp"]
        ),
        .executable(
            name: "DigiTributeTestRunner",
            targets: ["DigiTributeTestRunner"]
        )
    ],
    targets: [
        .target(
            name: "DigiTributeCore",
            path: "DigiTributeCore"
        ),
        .executableTarget(
            name: "DigiTributeApp",
            dependencies: ["DigiTributeCore"],
            path: "Sources/DigiTributeApp"
        ),
        .executableTarget(
            name: "DigiTributeTestRunner",
            dependencies: ["DigiTributeCore"],
            path: "Sources/DigiTributeTestRunner"
        )
    ]
)
