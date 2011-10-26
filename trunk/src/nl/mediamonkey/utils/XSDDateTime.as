package nl.mediamonkey.utils {
	import flash.utils.getTimer;
	
	/**
	 * @see http://www.w3schools.com/schema/schema_dtypes_date.asp
	 */
	
	public class XSDDateTime {
		
		// units are in seconds
		protected static const SECOND		:uint = 1;
		protected static const MINUTE		:uint = 60;
		protected static const HOUR			:uint = 3600;
		protected static const DAY			:uint = 86400;
		protected static const MONTH		:Number = 31556926/12; // = 2629743.8333~
		protected static const YEAR			:uint = 31556926;
		
		protected static var datePattern		:RegExp = /(\d{4})-(0\d|1[012])-([012]\d|3[01])/;
		protected static var timePattern		:RegExp = /([01]\d|2[0-3]):([0-5]\d):([0-5]\d(?:.\d{1,3})?)/;
		protected static var timeZonePattern	:RegExp = /(Z)|(\+|-)([01]\d|2[0-3]):([0-5]\d)/;
		protected static var durationPattern	:RegExp = /(-)?P(\d+Y)?(\d+M)?(\d+D)?(?:T(\d+H)?(\d+M)?(\d+S)?)?/;
		
		// YYYY-MM-DD
		// pattern: (\d{4})-(0\d|1[012])-([012]\d|3[01])
		public static function dateToDateString(value:Date, useUTC:Boolean=false):String {
			if (!useUTC) {
				return value.fullYear+"-"+inflate(value.month+1, "0", 2)+"-"+inflate(value.date, "0", 2);
			
			} else {
				var str:String = value.fullYearUTC+"-"+inflate(value.monthUTC+1, "0", 2)+"-"+inflate(value.dateUTC, "0", 2);
				str += dateToTimezone(value);
				return str;
			}
		}
		
		public static function stringToDate(value:String):Date {
			var date:Date = new Date();
			
			var result:Object = datePattern.exec(value);
			
			date.fullYear = parseInt(result[1]);
			date.month = parseInt(result[2]) - 1;
			date.date = parseInt(result[3]);
			
			return date;
		}
		
		// hh:mm:ss
		// pattern: ([01]\d|2[0-3]):([0-5]\d):([0-5]\d(?:.\d{1,3})?)
		public static function dateToTimeString(value:Date, useUTC:Boolean=false):String {
			if (!useUTC) {
				return inflate(value.hours, "0", 2)+":"+inflate(value.minutes, "0", 2)+":"+inflate(value.seconds, "0", 2);
				
			} else {
				var str:String = inflate(value.hoursUTC, "0", 2)+":"+inflate(value.minutesUTC, "0", 2)+":"+inflate(value.secondsUTC, "0", 2);
				str += dateToTimezone(value);
				return str;
			}
		}
		
		public static function stringToTime(value:String):Date {
			var date:Date = new Date();
			
			var result:Object = timePattern.exec(value);
			var useUTC:Boolean = timeZonePattern.test(value);
			
			if (!useUTC) {
				date.hours = parseInt(result[1]);
				date.minutes = parseInt(result[2]);
				date.seconds = parseFloat(result[3]);
				
			} else {
				var zoneResult:Object = timeZonePattern.exec(value);
				if (zoneResult[1] == "Z") return date;
				
				var positive:Boolean = (zoneResult[1] == "+");
				var hours:int = parseInt(zoneResult[2]);
				var minutes:int = parseInt(zoneResult[3]);
				
				var timezoneOffset:Number = (hours * 60 + minutes * -1);
				
				date.hoursUTC = parseInt(result[1]);
				date.minutesUTC = parseInt(result[2]) + timezoneOffset;
				date.secondsUTC = parseFloat(result[3]);
			}
			
			return date;
		}
		
		// YYYY-MM-DDThh:mm:ss
		public static function dateToDateTimeString(value:Date, useUTC:Boolean=false):String {
			return dateToDateString(value) + "T" + dateToTimeString(value, useUTC);
		}
		
		public static function stringToDateTime(value:String):Date {
			var d1:Date = stringToDate(value);
			var d2:Date = stringToTime(value);
			
			var date:Date = new Date();
			date.fullYear = d1.fullYear;
			date.month = d1.month;
			date.date = d1.date;
			date.hours = d2.hours;
			date.minutes = d2.minutes;
			date.seconds = d2.seconds;
			
			return date;
		}
		
		/**
		 * @return string with pattern: Z or +02:00 or -02:00
		 */
		// pattern: (Z)|(\+|-)([01]\d|2[0-3]):([0-5]\d)
		public static function dateToTimezone(value:Date):String {
			if (value.timezoneOffset == 0) {
				return "Z";
				
			} else {
				var diffHours:Number = value.timezoneOffset / -60;
				var offset:String = inflate(diffHours, "0", 2) + ":00";
				return (diffHours > 0) ? "+" + offset : offset; // negative value already contains a "-" char
			}
		}
		
		public static function stringToTimezoneOffset(value:String):Number {
			var result:Object = timeZonePattern.exec(value);
			
			return 0;
		}
		
		/**
		 * @return string with pattern: (-)PnYnMnDTnHnMnS
		 * 
		 * @example
		 * trace(XSDDateTime.secondsToDurationString(31556926 + 2629743.83 + 86400 + 3600 + 60 + 1));
		 */
		// pattern: (-)?P(\d+Y)?(\d+M)?(\d+D)?(?:T(\d+H)?(\d+M)?(\d+S)?)?
		public static function secondsToDurationString(seconds:Number):String {
			var str:String = (seconds < 0) ? "-P" : "P";
			
			var years:int = Math.floor(seconds / YEAR);
			if (years > 0) {
				str += years+"Y";
				seconds -= years * YEAR;
			}
			var months:int = Math.floor(seconds / MONTH);
			if (months > 0) {
				str += months+"M";
				seconds -= months * MONTH;
			}
			var days:int = Math.floor(seconds / DAY);
			if (days > 0) {
				str += days+"D";
				seconds -= days * DAY;
			}
			
			// if we still have milliseconds, add time
			if (seconds > 0) str += "T";
			
			var hours:int = Math.floor(seconds / HOUR);
			if (hours > 0) {
				str += hours+"H";
				seconds -= hours * HOUR;
			}
			var minutes:int = Math.floor(seconds / MINUTE);
			if (minutes > 0) {
				str += minutes+"M";
				seconds -= minutes * MINUTE;
			}
			if (seconds > 0) {
				str += Math.round(seconds)+"S";
			}
			
			return str;
		}
		
		public static function stringToDuration(value:String):Number {
			var result:Object = durationPattern.exec(value);
			
			var positive:Boolean = (result[1] == undefined);
			var years:int = parseInt(result[2]);
			var months:int = parseInt(result[3]);
			var days:int = parseInt(result[4]);
			var hours:int = parseInt(result[5]);
			var minutes:int = parseInt(result[6]);
			var seconds:int = parseInt(result[7]);
			
			return (years * YEAR + months * MONTH + days * DAY + hours * HOUR + minutes * MINUTE + seconds) * (positive ? 1 : -1);
		}
		
		// ----
		
		protected static function inflate(input:*, character:String, amount:uint):String {
			var str:String = input.toString();
			
			if (str.length < amount) {
				amount = amount - str.length;
				
				for (var i:int=0; i<amount; i++) {
					str = character + str;
				}
			}
			
			return str;
		}
		
		public static function test():void {
			var now:Date = new Date();
			
			trace("current date:", now);
			
			trace("-- Date to string --");
			trace("date:", dateToDateString(now));
			trace("time:", dateToTimeString(now));
			trace("dateTime:", dateToDateTimeString(now));
			trace("duration:", secondsToDurationString(now.hours * HOUR + now.minutes * MINUTE + now.seconds));
			
			trace("-- UTF Date to string --");
			trace("date:", dateToDateString(now, true));
			trace("time:", dateToTimeString(now, true));
			trace("dateTime:", dateToDateTimeString(now, true));
			
			trace("-- string to Date --");
			trace("date:", stringToDate("2011-10-26"));
			trace("time:", stringToTime("15:43:13"));
			trace("dateTime:", stringToDateTime("2011-10-26T15:43:13"));
			trace("duration:", stringToDuration("P1Y1DT0H2M59S"), "seconds");
			
			trace("-- string to UTF Date --");
			trace("date:", stringToDate("2011-10-26+02:00"));
			trace("time:", stringToTime("15:43:13+02:00"));
			trace("dateTime:", stringToDateTime("2011-10-26T15:43:13+02:00"));
		}
		
	}
}