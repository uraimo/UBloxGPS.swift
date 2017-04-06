import SwiftyGPIO //Comment this when compiling with swiftc
import UBloxGPS

let uarts = SwiftyGPIO.UARTs(for:.RaspberryPi2)!
var uart = (uarts?[0])!

let gps = UBloxGPS(uart)




