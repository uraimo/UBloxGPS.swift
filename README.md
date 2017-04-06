# UBloxGPS.swift

*A Swift library for boards with the u-Blox 6/7/8 family of A-GPS receivers with an UART serial connection.*

<p>
<img src="https://img.shields.io/badge/os-linux-green.svg?style=flat" alt="Linux-only" />
<a href="https://developer.apple.com/swift"><img src="https://img.shields.io/badge/swift3-compatible-4BC51D.svg?style=flat" alt="Swift 3 compatible" /></a>
<a href="https://raw.githubusercontent.com/uraimo/UBloxGPS.swift/master/LICENSE"><img src="http://img.shields.io/badge/license-MIT-blue.svg?style=flat" alt="License: MIT" /></a>
</p>
 

# Summary

This library interfaces with boards based on u-Blox 6/7/8 A-GPS receivers, that use the NMEA protocol to provide GPS data over an UART serial connection (most NEO6M boards, that I recommend, cost a measly $20). UBX configuration commands and connection via I2C are not supported at the moment.

You'll be able to retrieve you current location, elevation, speed, status data on the currently reachable satellites and more.

The first time you'll use the receiver it will need a few minutes to find some satellites and provide a position, but after that a few seconds will be enough to obtain a valid position.

![NEO6M board](https://github.com/uraimo/UBloxGPS.swift/raw/master/gps.jpg)

## Supported Boards

Every board supported by [SwiftyGPIO](https://github.com/uraimo/SwiftyGPIO) with support for UART interfaces.

To use this library, you'll need a Linux ARM board with Swift 3.x.

The example below will use a RaspberryPi 2 board but you can easily modify the example to use one the the other supported boards, a full working demo projects for the RaspberryPi2 is available in the `Examples` directory.

## Usage

The first thing we need to do is to obtain an instance of `UARTInterface` from SwiftyGPIO and use it to initialize the `UBloxGPS` object:

```swift
import SwiftyGPIO
import UBloxGPS

let uarts = SwiftyGPIO.UARTs(for:.RaspberryPi2)!
var uart = uarts[0]

let gps = UBloxGPS(uart)
```

We must than start the background thread that will update the GPS location and other information calling `startUpdating`. The library allows to print a recap of all available data with `printStatus`:

```swift
gps.startUpdating()

// We'll simply clear the screen and print a recap of the current gps data
while true {
   system("clear")
   gps.printStatus()
   sleep(2)
}
```

The `UBloxGPS` object has some accessible properties that you can use to retrieve the specific data you need:

| Property | Description |
|-----------|------------|
| isDataValid | Is the current GPS data valid for the receiver? |
| datetime | Date and time in stringified format |
| latitude | Latitude in degrees |
| longitude | Longitude in degrees |
| satellitesActiveNum | Number of active satellites (visible and actually being received) |
| satellitesNum | Number of satellites visible |
| altitude | Altitude from sea level |
| altitudeUnit | Unit for altitude |

Whe you don't need to update the location data just call `stopUpdating()`.


## Installation

Please refer to the [SwiftyGPIO](https://github.com/uraimo/SwiftyGPIO) readme for Swift installation instructions.

Once your board runs Swift, if your version support the Swift Package Manager, you can simply add this library as a dependency of your project and compile with `swift build`:

```swift
  let package = Package(
      name: "MyProject",
      dependencies: [
    .Package(url: "https://github.com/uraimo/UBloxGPS.swift.git", majorVersion: 1),
    ...
      ]
      ...
  ) 
```

The directory `Examples` contains sample projects that uses SPM, compile it and run the sample with `./.build/debug/TestNEO6M`.

If SPM is not supported, you'll need to manually download the library and its dependencies: 

    wget https://raw.githubusercontent.com/uraimo/UBloxGPS.swift/master/Sources/UBloxGPS.swift https://raw.githubusercontent.com/uraimo/SwiftyGPIO/master/Sources/SwiftyGPIO.swift https://raw.githubusercontent.com/uraimo/SwiftyGPIO/master/Sources/Presets.swift https://raw.githubusercontent.com/uraimo/SwiftyGPIO/master/Sources/UART.swift https://raw.githubusercontent.com/uraimo/SwiftyGPIO/master/Sources/SunXi.swift  

And once all the files have been downloaded, create an additional file that will contain the code of your application (e.g. main.swift). When your code is ready, compile it with:

    swiftc *.swift

The compiler will create a **main** executable.

