// swift-tools-version:5.9
/**
 * Copyright (c) 2025 Bivex
 *
 * Author: Bivex
 * Available for contact via email: support@b-b.top
 * For up-to-date contact information:
 * https://github.com/bivex
 *
 * Created: 2025-12-27T20:31:19
 * Last Updated: 2025-12-28T14:10:50
 *
 * Licensed under the MIT License.
 * Commercial licensing available upon request.
 */

import PackageDescription

let package = Package(
    name: "McpSwitcher",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(name: "mcp-switcher", targets: ["McpSwitcher"]),
        .executable(name: "mcp-tray", targets: ["McpTray"])
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.3.0"),
        .package(url: "https://github.com/stephencelis/SQLite.swift.git", from: "0.14.0"),
        .package(url: "https://github.com/apple/swift-log.git", from: "1.5.0")
    ],
    targets: [
        .target(
            name: "Domain",
            path: "Sources/Domain"
        ),
        .target(
            name: "Infrastructure",
            dependencies: ["Domain", .product(name: "SQLite", package: "SQLite.swift")],
            path: "Sources/Infrastructure"
        ),
        .target(
            name: "Application",
            dependencies: ["Domain", "Infrastructure"],
            path: "Sources/Application"
        ),
        .executableTarget(
            name: "McpSwitcher",
            dependencies: [
                "Application",
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "Logging", package: "swift-log")
            ],
            path: "Sources/Presentation/CLI"
        ),
        .executableTarget(
            name: "McpTray",
            dependencies: [
                "Application",
                .product(name: "SQLite", package: "SQLite.swift")
            ],
            path: "Sources/Tray",
            linkerSettings: [
                .linkedFramework("AppKit"),
                .linkedFramework("SwiftUI")
            ]
        ),
        .testTarget(
            name: "McpSwitcherTests",
            dependencies: ["Application"],
            path: "Tests"
        )
    ]
)

