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
            url: "https://github.com/pace/cloud-sdk-ios/releases/download/15.0.0/PACECloudSlimSDK.zip",
            checksum: "643859946f63cd3c4efe887eaae3d60cb63621da0f31ec943020d0cb07d98ba4"
        ),
        .binaryTarget(
            name: "PACECloudWatchSDK",
            url: "https://github.com/pace/cloud-sdk-ios/releases/download/15.0.0/PACECloudWatchSDK.zip",
            checksum: "85d44a6965cc050cabce5f2df795df9eb315cb84cf76777d97708319b20817c7"
        )
    ]
)
