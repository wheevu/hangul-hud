// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "HangulHUD",
    platforms: [.macOS(.v13)],
    products: [
        .executable(name: "HangulHUD", targets: ["HangulHUD"])
    ],
    targets: [
        .executableTarget(
            name: "HangulHUD",
            path: "HangulHUD",
            exclude: ["Info.plist"],
            resources: [.process("Resources")]
        )
    ]
)
