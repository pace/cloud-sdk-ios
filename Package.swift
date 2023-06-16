// swift-tools-version:5.5

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
            targets: ["PACECloudSDK"]),
        .library(
            name: "PACECloudSlimSDK",
            targets: ["PACECloudSlimSDK"]
        ),
        .library(
            name: "PACECloudWatchSDK",
            targets: ["PACECloudWatchSDK"]
        )
    ],
    dependencies: [
        .package(name: "AppAuth", url: "https://github.com/pace/AppAuth-iOS", .exact("1.5.0")),
        .package(name: "SwiftProtobuf", url: "https://github.com/apple/swift-protobuf.git", .exact("1.15.0")),
        .package(name: "Japx", url: "https://github.com/pace/Japx", .exact("5.0.0")),
    ],
    targets: [
        .target(
            name: "PACECloudSDK",
            dependencies: [
                "AppAuth",
                "SwiftProtobuf",
                "Japx"
            ],
            path: "PACECloudSDK",
            exclude: [
                "Info.plist",
                "API/POI/Generated/README.md",
                "API/Pay/Generated/README.md",
                "API/Fueling/Generated/README.md",
                "API/User/Generated/README.md"
            ],
            resources: [
                .process("Utils/Plists"),
                .process("AppKit/Assets/Images"),
                .process("POIKit/POIKitApi/Model/tile_query_request.proto"),
                .process("POIKit/POIKitApi/Model/tile_query_response.proto"),
                .process("POIKit/POISearch/Model/vector_tile.proto")
            ]),
        .binaryTarget(
            name: "PACECloudSlimSDK",
            url: "https://github.com/pace/cloud-sdk-ios/releases/download/16.0.0/PACECloudSlimSDK.zip",
            checksum: "7dc1793689467eba346d1e2a47968a14c05412282514b13c909bddb5ae72f9f5"
        ),
        .binaryTarget(
            name: "PACECloudWatchSDK",
            url: "https://github.com/pace/cloud-sdk-ios/releases/download/16.0.0/PACECloudWatchSDK.zip",
            checksum: "38457949cfc95cd309a9ae549bd4e4b1fbd0ae7dc72896a706f781f9febbc1a8"
        )
    ]
)
