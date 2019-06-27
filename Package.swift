// swift-tools-version:5.0
import PackageDescription

let package = Package(
    name: "LineSDK",
    platforms: [.iOS(.v10)],
    products: [
        .library(name: "LineSDK", targets: ["LineSDK"]),
    ],
    targets: [
        .target(
            name: "LineSDK",
            path: "LineSDK/LineSDK",
            exclude: ["LineSDKUI"]
        )
    ]
)
