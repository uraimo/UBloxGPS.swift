import PackageDescription

let package = Package(
    name: "TestNEO6M",
    dependencies: [
        .Package(url: "https://github.com/uraimo/UBloxGPS.swift.git",
                 majorVersion: 2)
    ]
)
