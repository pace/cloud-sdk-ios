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
            url: "https://github.com/pace/cloud-sdk-ios/releases/download/23.0.0/PACECloudSlimSDK.zip",
            checksum: "a0f5a14ff974a6a0e621d264fabf29a345fcf17a31060eaf9487d1945c5ce21f"
        ),
        .binaryTarget(
            name: "PACECloudWatchSDK",
            url: "https://github.com/pace/cloud-sdk-ios/releases/download/23.0.0/PACECloudWatchSDK.zip",
            checksum: "940bc38481508a664703bcf4b1d9c38aa22d292836b344e410f8ccb2b94eb770"
        )
    ]
)
