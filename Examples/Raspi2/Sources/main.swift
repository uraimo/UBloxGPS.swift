import SwiftyGPIO //Comment this when compiling with swiftc
import UBloxGPS

let uarts = SwiftyGPIO.UARTs(for:.RaspberryPi2)!
var uart = uarts[0]

let gps = UBloxGPS(uart)

/*
Accessible UBloxGPS fields:

/// Is the current GPS data valid for the receiver?
var isDataValid
/// Date and time in stringified format
var datetime
/// Latitude in degrees
var latitude
/// Longitude in degrees
var longitude
/// Number of active satellites (visible and actually being received)
var satellitesActiveNum
/// Number of satellites visible
var satellitesNum
/// Altitude from sea level
var altitude
/// Unit for altitude
var altitudeUnit
*/

gps.startUpdating()


// We'll simply clear the screen and print a recap of the current gps data
while true {
   system("clear")
   gps.printStatus()
   sleep(2)
}
