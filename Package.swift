// swift-tools-version:5.0
import PackageDescription

let package = Package(
    name: "RxFileMonitor",
    platforms: [
        .macOS(.v10_11),
    ],
    products: [
        .library(name: "RxFileMonitor", targets: ["RxFileMonitor"]),
    ],
    dependencies: [
        .package(url: "https://github.com/ReactiveX/RxSwift", from: "5.0.0"),
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