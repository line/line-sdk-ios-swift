// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "LineSDK",
    defaultLocalization: "en",
    platforms: [.iOS(.v10)],
    products: [
        .library(name: "LineSDK", targets: ["LineSDK"]),
        .library(name: "LineSDKObjC", targets: ["LineSDKObjC"])
    ],
    targets: [
        .target(
            name: "LineSDK",
            path: "LineSDK/LineSDK",
            exclude: [
                "Info.plist"
            ],
            resources: [
                .process("Resource.bundle")
            ]
        ),
        .target(
            name: "LineSDKObjC",
            dependencies: ["LineSDK"],
            path: "LineSDK/LineSDKObjC",
            exclude: [
                "Info.plist"
            ]
        )
    ]
)
