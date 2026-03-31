// swift-tools-version: 6.3

import PackageDescription
import CompilerPluginSupport

let package = Package(
    name: "Beholder",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(
            name: "Beholder",
            targets: ["Beholder"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/swiftlang/swift-syntax.git", from: "603.0.0-latest"),
    ],
    targets: [
        .macro(
            name: "BeholderMacros",
            dependencies: [
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
            ]
        ),
        .target(
            name: "Beholder",
            dependencies: ["BeholderMacros"],
            path: "Sources/Beholder"
        ),
        .testTarget(
            name: "BeholderTests",
            dependencies: ["Beholder"],
            path: "Tests/BeholderTests"
        ),
        .testTarget(
            name: "BeholderMacroTests",
            dependencies: [
                "BeholderMacros",
                .product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax"),
            ],
            path: "Tests/BeholderMacroTests"
        ),
    ]
)
