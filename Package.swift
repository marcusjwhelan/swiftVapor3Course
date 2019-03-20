// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "MiniPost",
    products: [
        .library(name: "MiniPost", targets: ["App"]),
    ],
    dependencies: [
        // 💧 A server-side Swift web framework.
        .package(url: "https://github.com/vapor/vapor.git", from: "3.0.0"),

        // 🔵 Swift ORM (queries, models, relations, etc) built on SQLite 3.
        // .package(url: "https://github.com/vapor/fluent-sqlite.git", from: "3.0.0"),
        // use mysql
        .package(url: "https://github.com/vapor/fluent-mysql.git", from: "3.0.0"),
        
        // add new package leaf
        .package(url: "https://github.com/vapor/leaf.git", from: "3.0.0"),
                
        // for auth
        .package(url: "https://github.com/vapor/auth.git", from: "2.0.3")
    ],
    targets: [
        // .target(name: "App", dependencies: ["FluentSQLite", "Vapor", "Leaf", "Authentication"]),
        .target(name: "App", dependencies: ["FluentMySQL", "Vapor", "Leaf", "Authentication"]),
        .target(name: "Run", dependencies: ["App"]),
        .testTarget(name: "AppTests", dependencies: ["App"])
    ]
)

