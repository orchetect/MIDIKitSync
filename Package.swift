// swift-tools-version:5.3

import PackageDescription

let package = Package(
    
    name: "MIDIKitSync",

    platforms: [
        .macOS(.v10_12), .iOS(.v10), .tvOS(.v10), .watchOS(.v3)
    ],

    products: [
        .library(
            name: "MIDIKitSync",
            type: .static,
            targets: ["MIDIKitSync"]
        ),
    ],

    dependencies: [
        .package(url: "https://github.com/orchetect/MIDIKit", from: "0.5.0"),
        .package(url: "https://github.com/orchetect/TimecodeKit", from: "1.2.9"),
        
        // testing-only:
        .package(url: "https://github.com/orchetect/XCTestUtils", from: "1.0.1")
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
                .product(name: "TimecodeKit", package: "TimecodeKit"),
                .product(name: "XCTestUtils", package: "XCTestUtils")
            ]
        )
    ]
    
)

func addShouldTestFlag() {
    // swiftSettings may be nil so we can't directly append to it
    
    var swiftSettings = package.targets
        .first(where: { $0.name == "MIDIKitSyncTests" })?
        .swiftSettings ?? []
    
    swiftSettings.append(.define("shouldTestCurrentPlatform"))
    
    package.targets
        .first(where: { $0.name == "MIDIKitSyncTests" })?
        .swiftSettings = swiftSettings
}

// Swift version in Xcode 12.5.1 which introduced watchOS testing
#if os(watchOS) && swift(>=5.4.2)
addShouldTestFlag()
#elseif os(watchOS)
// don't add flag
#else
addShouldTestFlag()
#endif
