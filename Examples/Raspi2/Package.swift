import PackageDescription

let package = Package(
    name: "TestNEO6M",
    targets: [],
    dependencies: [
        .Package(url: "https://github.com/uraimo/UBloxGPS.swift.git",
                 majorVersion: 1)
    ]
)
