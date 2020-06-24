// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "LeafDriver",
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "LeafDriver",
            targets: ["LeafDriver"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(name: "CryptoSwift", url: "https://github.com/krzyzanowskim/CryptoSwift.git", .upToNextMajor(from:"1.2.0")),
        .package(name: "SiriDriver", url: "https://github.com/TheMisfit68/SiriDriver.git", .branch("master"))
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "LeafDriver",
            dependencies: ["CryptoSwift", "SiriDriver"])
    ]
)
