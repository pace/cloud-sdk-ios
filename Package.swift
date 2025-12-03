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
        .package(name: "IkigaJSON", url: "https://github.com/Ikiga/IkigaJSON.git", .exact("2.3.2")),
    ],
    targets: [
        .target(
            name: "PACECloudSDK",
            dependencies: [
                "AppAuth",
                "SwiftProtobuf",
                "Japx",
                "IkigaJSON"
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
            url: "https://github.com/pace/cloud-sdk-ios/releases/download/25.2.0/PACECloudSlimSDK.zip",
            checksum: "8d1bca2d481e3c17e581b44979a9615edcb0b5faa65ab6233b52ad8a080d1739"
        ),
        .binaryTarget(
            name: "PACECloudWatchSDK",
            url: "https://github.com/pace/cloud-sdk-ios/releases/download/25.2.0/PACECloudWatchSDK.zip",
            checksum: "061c6b731fff9a0c6edd940126689a315e5c17c87eb3795a75b43e8d1afa6eee"
        )
    ]
)
