// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "droplet",
    products: [
        .library(name: "droplet", targets: ["App"]),
    ],
    dependencies: [
        .package(url: "https://github.com/vapor/fluent-postgres-driver.git", from: "1.0.0"),
        .package(url: "https://github.com/vapor/leaf.git", from: "3.0.2"),
        // 💧 A server-side Swift web framework.
        .package(url: "https://github.com/vapor/vapor.git", from: "3.0.0"),

        // 🔵 Swift ORM (queries, models, relations, etc) built on SQLite 3.
        .package(url: "https://github.com/vapor/fluent-sqlite.git", from: "3.0.0")
    ],
    targets: [
        .target(name: "App", dependencies: ["FluentSQLite", "Vapor", "Leaf", "FluentPostgreSQL"]),
        .target(name: "Run", dependencies: ["App"]),
        .testTarget(name: "AppTests", dependencies: ["App"])
    ]
)

