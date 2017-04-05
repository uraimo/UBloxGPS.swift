import SwiftyGPIO
import NEO6GPS

let uarts = SwiftyGPIO.UARTs(for:.RaspberryPi2)!
let uart = uart[0]

let gps = NEO6GPS(uart)




