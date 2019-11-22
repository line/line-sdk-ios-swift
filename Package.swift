// swift-tools-version:5.0
import PackageDescription

let package = Package(
    name: "LineSDK",
    platforms: [.iOS(.v10)],
    products: [
        .library(name: "LineSDK", targets: ["LineSDK"]),
        .library(name: "LineSDKObjC", targets: ["LineSDKObjC"])
    ],
    targets: [
        .target(
            name: "LineSDK",
            path: "LineSDK/LineSDK",
            exclude: ["LineSDKUI"]
        ),
        .target(
            name: "LineSDKObjC",
            dependencies: ["LineSDK"],
            path: "LineSDK/LineSDKObjC",
            exclude: ["LineSDKUI"]
        )
    ]
)
