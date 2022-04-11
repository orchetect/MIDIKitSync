// swift-tools-version:5.3

import PackageDescription

let package = Package(
    
    name: "MIDIKitSync",

    platforms: [
        .macOS(.v10_12), .iOS(.v10)
    ],

    products: [
        .library(
            name: "MIDIKitSync",
            type: .static,
            targets: ["MIDIKitSync"]
        ),
    ],

    dependencies: [
        .package(url: "https://github.com/orchetect/MIDIKit", from: "0.4.4"),
        .package(url: "https://github.com/orchetect/TimecodeKit", from: "1.2.9")
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
