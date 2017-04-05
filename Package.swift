import PackageDescription

let package = Package(
    name: "UBloxGPS",
    targets: [],
    dependencies: [
        .Package(url: "https://github.com/uraimo/SwiftyGPIO.git",
                 majorVersion: 0)
    ]
)
