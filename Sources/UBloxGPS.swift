/*
   UBloxGPS.swift

   Copyright (c) 2017 Umberto Raimondi
   Licensed under the MIT license, as follows:

   Permission is hereby granted, free of charge, to any person obtaining a copy
   of this software and associated documentation files (the "Software"), to deal
   in the Software without restriction, including without limitation the rights
   to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
   copies of the Software, and to permit persons to whom the Software is
   furnished to do so, subject to the following conditions:

   The above copyright notice and this permission notice shall be included in all
   copies or substantial portions of the Software.

   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
   IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
   FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
   AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
   LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
   OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
   SOFTWARE.)
*/

import SwiftyGPIO  //Comment this when not using the package manager
import Foundation


public class UBloxGPS{
   var uart: UARTInterface
   var updateThread: Thread?
   var running = false

   /// Is the current GPS data valid for the receiver?
   public var isDataValid = false
   /// Date and time in stringified format
   public var datetime = "N/A"
   /// Latitude in degrees
   public var latitude: Double = 0
   /// Longitude in degrees
   public var longitude: Double = 0
   /// Number of active satellites (visible and actually being received)
   public var satellitesActiveNum = 0
   /// Number of satellites visible
   public var satellitesNum = 0
   /// Altitude from sea level
   public var altitude: Double = 0
   /// Unit for altitude
   public var altitudeUnit: String = "N/A"

   // Internal fields for quadrant location used to compute lat/lon
   var NS: Int = 1
   var EW: Int = 1

   /// Struct with Satellite data
   public struct SatData{
      let id: Int
      let elevation: Int //in degrees 0..60
      let azimuth: Int   //in degrees 0..360
      let snr: Int       // snr in dB
   }
   /// Collection with the current satellites, no more than 12
   public var satellites = [SatData](repeating: SatData(id: 0,elevation: 0,azimuth: 0,snr: 0),count: 12) //12 Satellites max


   /// Initializer for UBloxGPS
   ///
   /// - Parameter uart: UART interface that will be used
   ///
   public init(_ uart: UARTInterface) {
       self.uart = uart
       uart.configureInterface(speed: .S9600, bitsPerChar: .Eight, stopBits: .One, parity: .None)
   }

   /// Starts updating the GPS data in a background Thread
   public func startUpdating(){
      if updateThread == nil {
         updateThread = Thread{ [unowned self] in
            self.update()
         }
      }
      running = true
      updateThread!.start()
   }

   /// Stop reading GPS data
   public func stopUpdating(){
      running = false
      updateThread = nil
   }

   /// Prints all the current data
   public func printStatus(){
      print("GPS Values are",(isDataValid ? "valid." : "invalid."))
      print("Date:", datetime)
      print("Latitude:",latitude,"Longitude:",longitude)
      print("Altitude:",altitude,altitudeUnit)
      print("Visible satellites:",satellitesNum)
      print("Active satellites:",satellitesActiveNum)
      print("----------------------------------------------------------------------")
      satellites.forEach {
         print("Satellite Id:",$0.id,"Elevation(deg):",$0.elevation, 
               "Azimuth(deg):",$0.azimuth, "SNR(dB):", $0.snr)
      }
   }

   private func update(){
      while running {
         let s = uart.readLine()
         parseNMEA(s)
      }
   }

   /// Parse the NMEA0183 protocol strings that follow the format:
   ///
   /// $ttsss,d1,d2,...,dn<CR><LF>
   ///
   /// - Parameter text: a string conforming to the protocol
   ///
   private func parseNMEA(_ text: String){
      let comp = text.components(separatedBy: ",")

      switch comp[0] { //$ttsss
         case "$GPRMC":
            // time,valid,lat,NorS,lon,EorW,speed,course,date,magn,EorW,ck
            // time= hhmmss.ss, date= ddmmyy
            datetime = comp[9]+" "+String(comp[1].characters.dropLast(3))

            isDataValid = (comp[2] == "A")
            // quadrants, will be used to apply the right sign to lat/lon
            NS = (comp[2] == "N") ? -1 : 1
            EW = (comp[6] == "E") ? 1 : -1

            // latitude and longitude in degrees+minutes format
            latitude = Double(String(comp[3].characters.prefix(2)))! + 
                        Double(String(comp[3].characters.dropFirst(2)))!/60
            latitude *= Double(NS)
            latitude = latitude.roundTo(places: 8)
            longitude = Double(String(comp[5].characters.prefix(3)))! + 
                         Double(String(comp[5].characters.dropFirst(3)))!/60
            longitude *= Double(EW)
            longitude = longitude.roundTo(places: 8)
         case "$GPGGA":
            // time,lat,NorS,lon,EorW,quality,numSats,Hdiluition,altitude,unitAltitude,geoidsep,unitGeoidsep,dataAge,[missing in ublox],ck
            satellitesActiveNum = Int(comp[7]) ?? 0
            altitude = Double(comp[9]) ?? 0
            altitudeUnit = comp[10]
         case "$GPGSV":
            // Satellite info (multiple records, 4 sats per record)
            // numGPGSV,gpgsvId,numSats,(repeated:4){satId,elevation,azimuth,snrdB},ck
            let msgId = Int(comp[2])!
            satellitesNum = Int(comp[3])!
            for i in 1...4 {
               guard comp.count >= (i*4+4) else { break } //No more elements in this GSV

               let id = Int(comp[i*4]) ?? 0
               let elevation = Int(comp[i*4+1]) ?? 0
               let azimuth = Int(comp[i*4+2]) ?? 0
               //snr could have trailing *ck without comma
               let snr = Int(comp[i*4+3].components(separatedBy: "*")[0]) ?? 0

               satellites[(msgId-1)*4+(i-1)] = SatData(id: id,elevation: elevation,azimuth: azimuth,snr: snr)
            }
         case "$GPVTG":
            // degree,T,degree,M,speedknots,N,speedKmph,K,ck
            fallthrough
         case "$GPGSA":
            // selmode,mode,satid,satid,satid,satid,satid,satid,satid,satid,satid,satid,satid,satid,pdop,hdop,vdop,ck
            fallthrough
         case "$GPGLL":
            // lat,NorS,lon,EorW,time,valid,ck
            fallthrough
         default:
            //Unrecognized or ignored string
            return
      }
   }

   deinit{
      stopUpdating()
   }
}

extension Double {
   func roundTo(places:Int) -> Double {
      let divisor = pow(10.0, Double(places))
      return (self * divisor).rounded() / divisor
   }
}

