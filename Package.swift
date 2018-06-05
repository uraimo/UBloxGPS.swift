import PackageDescription

let package = Package(
    name: "UBloxGPS",
    dependencies: [
        .Package(url: "https://github.com/uraimo/SwiftyGPIO.git",
                 majorVersion: 1)
    ]
)
