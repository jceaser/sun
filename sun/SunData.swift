/*
SunData.swift

Ported to swift from python by Thomas.Cherry@gmail.com on 2022-02-15.

This file is a direct port of a python file which calculates sun rise and set.
Python code is left in to see exactly what was changed and what was dropped.
 
Based on
 https://gist.github.com/jacopofar/ca2397944f56412e81a8882e565038af
 which is in turn based on
 https://michelanders.blogspot.com/2010/12/calulating-sunrise-and-sunset-in-python.html
 
 I did not find any license information for the code at these sites, I assume
 the code is in the public domain and I do not apply any license to this file
 that would change this.
 
 This file is in the public domain.
 
 https://en.wikipedia.org/wiki/Public_domain
 
*/

import Foundation


/*import os

from math import cos,sin,acos,asin,tan
from math import degrees as deg, radians as rad
from datetime import date,datetime,time

# this module is not provided here. See text.
#from timezone import LocalTimezone
*/
func LocalTimezone() -> Double {
    return Double(TimeZone.current.secondsFromGMT())/60.0/60.0
    //return timezone.utc
}
    
class Sun {
 /*
 Calculate sunrise and sunset based on equations from NOAA
 http://www.srrb.noaa.gov/highlights/sunrise/calcdetails.html

 typical use, calculating the sunrise at the present day:
 
 import datetime
 import sunrise
 s = sun(lat=49,long=3)
 print('sunrise at ',s.sunrise(when=datetime.datetime.now())
 */
    var lat: Double
    var long: Double
    var day: Double
    var timezone : Double
    var time: Double
    
    var solarnoon_t : Double
    var sunrise_t : Double
    var sunset_t : Double
    
    init(lat : Double,long : Double) {
        self.lat = lat
        self.long = long
        self.timezone = LocalTimezone()
        self.day = 0.0
        self.time = 0.0
        self.solarnoon_t = 0.0
        self.sunset_t = 0.0
        self.sunrise_t = 0.0
    }
    
    func sunrise(when: Date) -> String{
    /*
     return the time of sunrise as a datetime.time object
     when is a datetime.datetime object. If none is given
     a local time zone is assumed (including daylight saving
     if present)
    */
        //if when is None : when = datetime.now(tz=LocalTimezone())
        self.__preptime(when: when)
        self.__calc()
        return self.timefromdecimalday(day: self.sunrise_t)
    }
    func sunset(when :Date) -> String {
        //if when is None : when = datetime.now(tz=LocalTimezone())
        self.__preptime(when: when)
        self.__calc()
        return self.timefromdecimalday(day: self.sunset_t)
    }
  
    func solarnoon(when: Date) -> String {
        //if when is None : when = datetime.now(tz=LocalTimezone())
        self.__preptime(when: when)
        self.__calc()
        return self.timefromdecimalday(day: self.solarnoon_t)
    }
    
    func timefromdecimalday(day: Double) -> String { //DateComponents {
        /*
         returns a datetime.time object.
         day is a decimal day between 0.0 and 1.0, e.g. noon = 0.5
         */
        
        let hours   = 24.0*day
        let h       = Int(hours)
        let minutes = (hours-Double(h))*60.0
        let m       = Int(minutes)
        let seconds = (minutes-Double(m))*60.0
        let s       = Int(seconds)
        
        var dc = DateComponents()
        dc.hour = h
        dc.minute = m
        dc.second = s
        //return dc
        return "{\"hour\": \(h), \"minute\": \(m), \"second\": \(s)}"
        //return time(hour=h,minute=m,second=s)
    }
    
    func jdFromDate(date : Date) -> Double {
        let JD_JAN_1_1970_0000GMT = 2440587.5
        var ans = JD_JAN_1_1970_0000GMT + date.timeIntervalSince1970 / 86400.0
        ans = round(ans / 60.0)  + 3615.0 //correct for mac os x
        return ans
    }

    func __preptime(when: Date) {
        /*
         Extract information in a suitable format from when,
         a datetime.datetime object.
         */
        // datetime days are numbered in the Gregorian calendar
        // while the calculations from NOAA are distibuted as
        // OpenOffice spreadsheets with days numbered from
        // 1/1/1900. The difference are those numbers taken for
        // 18/12/2010
        //self.day = when.toordinal()-(734124-40529)
        let comp = NSCalendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute, .second],
            from: when)
        self.day  = self.jdFromDate(date: when)
        let h = Double(comp.hour!)
        let m = Double(comp.minute!)
        let s = Double(comp.second!)
        self.time = (h + m/60.0 + s/3600.0)/24.0
          
        //self.timezone=0
        /*offset=when.utcoffset()
        if not offset is None:
            self.timezone=offset.seconds/3600.0*/
    }
    
    func __calc() {
        /*
        Perform the actual calculations for sunrise, sunset and
        a number of related quantities.

        The results are stored in the instance variables
        sunrise_t, sunset_t and solarnoon_t
        */
        let timezone  = self.timezone // in hours, east is positive
        let longitude = self.long     // in decimal degrees, east is positive
        let latitude  = self.lat      // in decimal degrees, north is positive

        let time     = self.time // percentage past midnight, i.e. noon  is 0.5
        let day      = self.day     // daynumber 1=1/1/1900

        let Jday     = day + 2415018.5 + time - timezone / 24.0 // Julian day
        let Jcent    = (Jday - 2451545) / 36525.0    // Julian century
        
        let Manom    = 357.52911 + Jcent * (35999.05029 - 0.0001537 * Jcent)
        //let Mlong    = 280.46646 + Jcent * (36000.76983 + Jcent * 0.0003032) % 360
        let Mlong    = 280.46646 + (Jcent * (36000.76983 + Jcent * 0.0003032)).truncatingRemainder(dividingBy: 360)
        let Eccent   = 0.016708634 - Jcent * (0.000042037 + 0.0001537 * Jcent)
        let Mobliq   = 23.0 + (26.0 + ((21.448 - Jcent * (46.815 + Jcent * (0.00059 - Jcent * 0.001813)))) / 60.0) / 60.0
        let obliq    = Mobliq + 0.00256 * cos(rad(125.04 - 1934.136 * Jcent))
        let vary     = tan(rad(obliq/2))*tan(rad(obliq/2))
        let Seqcent   = sin(rad(Manom)) * (1.914602 - Jcent * (0.004817 + 0.000014 * Jcent)) + sin(rad(2.0 * Manom)) * (0.019993 - 0.000101 * Jcent) + sin(rad(3.0 * Manom)) * 0.000289
        let Struelong = Mlong+Seqcent
        let Sapplong = Struelong - 0.00569 - 0.00478 * sin(rad(125.04 - 1934.136 * Jcent))
        let declination = deg(asin(sin(rad(obliq)) * sin(rad(Sapplong))))
  
        let eqtime   = 4.0 * deg(vary * sin(2.0 * rad(Mlong)) - 2.0 * Eccent * sin(rad(Manom)) + 4.0 * Eccent * vary * sin(rad(Manom)) * cos(2 * rad(Mlong)) - 0.5 * vary * vary * sin(4  * rad(Mlong)) - 1.25 * Eccent * Eccent*sin(2 * rad(Manom)))
        
        let hourangle =  deg(acos(cos(rad(90.833)) /
                                  (cos(rad(latitude)) *
                                   cos(rad(declination))) -
                                  tan(rad(latitude)) *
                                  tan(rad(declination))))
        
        self.solarnoon_t = (720.0 - 4.0 * longitude - eqtime + timezone * 60.0) / 1440.0
        self.sunrise_t   = self.solarnoon_t - hourangle * 4.0 / 1440.0
        self.sunset_t    = self.solarnoon_t + hourangle * 4.0 / 1440.0
    }

    func rad(_ number: Double) -> Double {
        return number * Double.pi / 180.0
    }
    
    func deg(_ number: Double) -> Double {
        return number * 180.0 / Double.pi
    }
}
/*
 if __name__ == "__main__":
 s=sun(lat=39.2904,long=-76.6122)
 print(datetime.today())
 print(s.sunrise(),s.solarnoon(),s.sunset())
 */
