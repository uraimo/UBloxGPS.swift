// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "TestNEO6M",
    dependencies: [
        .package(url: "https://github.com/uraimo/SwiftyGPIO.git", from: "1.0.0"),
        .package(url: "https://github.com/uraimo/UBloxGPS.swift.git",from: "2.0.0")
    ],
    targets: [
        .target(name: "TestNEO6M", 
                dependencies: ["SwiftyGPIO","UBloxGPS"],
                path: "Sources")
    ]
) 