// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "SKsAppMenu",
    platforms: [.macOS("27.0")],
    products: [.library(name: "MenuCore", targets: ["MenuCore"])],
    targets: [
        .target(name: "MenuCore", path: "Sources/Core"),
        .testTarget(name: "MenuCoreTests", dependencies: ["MenuCore"], path: "Tests/CoreTests")
    ],
    swiftLanguageModes: [.v6]
)
