// swift-tools-version:5.5

import PackageDescription

let package = Package(
    name: "PACECloudSDK",
    defaultLocalization: "de",
    platforms: [
        .iOS(.v15),
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
        .package(name: "SwiftProtobuf", url: "https://github.com/apple/swift-protobuf.git", .exact("1.22.0")),
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
            url: "https://github.com/pace/cloud-sdk-ios/releases/download/21.0.0/PACECloudSlimSDK.zip",
            checksum: "69cc3ee1daffc13c2dec2488c1406312149546c23ee62448edb263a47ce93967"
        ),
        .binaryTarget(
            name: "PACECloudWatchSDK",
            url: "https://github.com/pace/cloud-sdk-ios/releases/download/21.0.0/PACECloudWatchSDK.zip",
            checksum: "d7a5302cd8c0fceaddd9027491f1573ab91d7a48891d3952bf41619b53c80ab3"
        )
    ]
)
