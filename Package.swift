// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "PACECloudSDK",
    defaultLocalization: "de",
    platforms: [
        .iOS(.v11),
        .macOS(.v10_15)
    ],
    products: [
        .library(
            name: "PACECloudSDK",
            type: .static,
            targets: ["PACECloudSDK"]),
        .library(
            name: "PACECloudSDKDynamic",
            type: .dynamic,
            targets: ["PACECloudSDK"])
    ],
    dependencies: [
        .package(name: "AppAuth", url: "https://github.com/openid/AppAuth-iOS.git", .branch("master")),
        .package(name: "SwiftProtobuf", url: "https://github.com/apple/swift-protobuf.git", .exact("1.13.0")),
        .package(name: "OneTimePassword", url: "https://github.com/bas-d/OneTimePassword", .branch("spm")),
    ],
    targets: [
        .target(
            name: "PACECloudSDK",
            dependencies: [
                "AppAuth",
                "SwiftProtobuf",
                "OneTimePassword",
            ],
            path: "PACECloudSDK",
            exclude: [
                "Info.plist",
                "API/POI/Generated/README.md",
                "API/Pay/Generated/README.md",
                "API/Fueling/Generated/README.md",
                "API/User/Generated/README.md",
                "API/GeoJSON/Generated/README.md",
            ],
            resources: [
                .process("Utils/Plists"),
                .process("AppKit/Assets/Fonts"),
                .process("POIKit/POIKitApi/Model/tile_query_request.proto"),
                .process("POIKit/POIKitApi/Model/tile_query_response.proto"),
                .process("POIKit/POISearch/Model/vector_tile.proto")
            ]),
        .testTarget(
            name: "PACECloudSDKTests",
            dependencies: ["PACECloudSDK"],
            path: "PACECloudSDKTests",
            exclude: [
                "Info.plist"
            ])
    ]
)
