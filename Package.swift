// swift-tools-version: 5.7
import PackageDescription

let package = Package(
    name: "RxFileMonitor",
    platforms: [
        .macOS(.v10_13),
    ],
    products: [
        .library(name: "RxFileMonitor", targets: ["RxFileMonitor"]),
    ],
    dependencies: [
        .package(url: "https://github.com/ReactiveX/RxSwift", from: "6.8.0"),
    ],
    targets: [
        .target(
            name: "RxFileMonitor",
            dependencies: ["RxSwift"],
            path: "RxFileMonitor",
            exclude: ["Info.plist"]
        )
    ]
)
