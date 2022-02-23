# Sun rise and setting times in Swift

Swift code to calculate sun rise and sun setting times based on timezone and latitude and longitude values. 

NOTE: This project is a direct port of python code to Swift code.

Based on
* [This Gist code][gist]
* [which is in turn based on this][orig]
 
## Usage
Getting help:

	>sun --help
	Returns JSON for the current raise and setting times of the sun.
	
	Flag Long Flag    : Description
	---- ------------ : ----------------------------------------------------------------
	-h   --help       : Help/Manual
	-l   --latitude   : Decimal value for latitude
	-L   --longitude  : Decimal value for longitude
	-t   --time-zone  : Offset in hours

Example call which returns JSON:

	>sun --latitude 38.88333 --longitude -77.03333 -t -5
	{
	"sunrise": {"hour": 6, "minute": 56, "second": 45} ,
	"noon": {"hour": 12, "minute": 22, "second": 7} ,
	"sunset": {"hour": 17, "minute": 47, "second": 29}
	}

Using [jq][jq] to pull out specific values:

	>sun -t 5 \
		--latitude 38.88333 \
		--longitude -77.03333 \
		| jq '.sunrise.hour,.sunrise.minute'
	6
	56

## Code
Create a Sun object with the latitude and longitude and set timezone offset if needed. Then call `sunrise`, `solarnoon`, `s.sunset` to get back JSON string.

	let s = Sun(lat: latitude, long: longitude)
	s.timezone = -5.0
	let rise: String = s.sunrise(when: Date()) //JSON string
	let noon: String = s.solarnoon(when: Date()) //JSON string
	let setting: String = s.sunset(when: Date()) //JSON string

Written and compiled with XCode Version 13.2.1 (13C100).

## License

There is a "donut hole" of licenses here. All files but one are under [BSD 2-Clause License][bsd2]. The exception is the [SunData.swift][sun-file] file which seams to be in the [public domain][public-domain].


BSD

[bsd2]: /LICENSE "BSD 2-Clause License"
[public-domain]: https://en.wikipedia.org/wiki/Public_domain "Public Domain Information"
[gist]: https://gist.github.com/jacopofar/ca2397944f56412e81a8882e565038af "Gist repository"
[sun-file]: sun/sun/SunData.swift "Sun calculation file"
[orig]: https://michelanders.blogspot.com/2010/12/calulating-sunrise-and-sunset-in-python.html "Original code"