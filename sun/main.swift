//
//  main.swift
//  sun
//
//  Created by Thomas Cherry on 2022-02-15.
//
// Not public domain
// BSD License
// it is my wish that people feel free to include this application in any
// distributions without restrictions.

import Foundation

// 39° 17' 25.4394"
// -76° 36' 43.92"

// equation of time -14.09
// solar declination -12.34

//http://thomascherry.name/cgi-bin/sun_server.cgi?offset=5&lat=39.2904&long=-76.6122

var latitude = 38.88333
var longitude = -77.03333

let s = Sun(lat: latitude, long: longitude)

var index = 0
var arg_count = CommandLine.arguments.count
while index < arg_count {
    let argument = CommandLine.arguments[index]
    let opt = (index+1) < arg_count ? CommandLine.arguments[index+1] : nil
    switch argument {
    case "-h", "--help":
        let line = {(s:String, l:String, m:String) in
            print(String(format: "%@ %@ : %@",
                         s.padding(toLength: 4, withPad: " ", startingAt: 0),
                         l.padding(toLength: 12, withPad: " ", startingAt: 0),
                         m.padding(toLength: 64, withPad: " ", startingAt: 0)))
        }
        print ("Returns JSON for the current raise and setting times of the sun.\n")
        line("Flag", "Long Flag", "Description")
        line("----", "------------", String(repeating: "-", count: 64))
        line("-h", "--help", "Help/Manual")
        line("-l", "--latitude", "Decimal value for latitude")
        line("-L", "--longitude", "Decimal value for longitude")
        line("-t", "--time-zone", "Offset in hours")

        exit(0)
    case "-l", "--latitude":
        if !(opt==nil) {
            s.lat = Double(opt!) ?? 38.88333
            index = index + 1
        }
    case "-L", "--longitude":
        if !(opt==nil) {
            s.long = Double(opt!) ?? -77.03333
            index = index + 1
        }
    case "-t", "--time-zone":
        if !(opt==nil) {
            s.timezone = Double(opt!) ?? -5
            index = index + 1
        }
    default:
        if argument.contains("sun") {
            break
        }
        print ("unknown option", argument)
    }
    index = index + 1
}

//let s = Sun(lat: 39.2904, long: -76.6122)

print ("{")
print ("\"sunrise\":", s.sunrise(when: Date()), ",")
print ("\"noon\":", s.solarnoon(when: Date()), ",")
print ("\"sunset\":", s.sunset(when: Date()))
print ("}")
