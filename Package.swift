// swift-tools-version:5.3

import PackageDescription

let package = Package(
    
    name: "MIDIKitSync",

    platforms: [
        .macOS(.v10_12), .iOS(.v10) // , .tvOS(.v14), .watchOS(.v7) - still in beta
    ],

    products: [
        .library(
            name: "MIDIKitSync",
            type: .static,
            targets: ["MIDIKitSync"]
        ),
    ],

    dependencies: [
        .package(url: "https://github.com/orchetect/MIDIKit", from: "0.2.1"),
        .package(url: "https://github.com/orchetect/TimecodeKit", from: "1.2.6")
    ],

    targets: [
        .target(
            name: "MIDIKitSync",
            dependencies: [
                .product(name: "MIDIKit", package: "MIDIKit"),
                .product(name: "TimecodeKit", package: "TimecodeKit")
            ]
        ),

        .testTarget(
            name: "MIDIKitSyncTests",
            dependencies: [
                .target(name: "MIDIKitSync"),
                .product(name: "TimecodeKit", package: "TimecodeKit")
            ]
        )
    ]
    
)
