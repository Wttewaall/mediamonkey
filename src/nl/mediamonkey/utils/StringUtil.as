package nl.mediamonkey.utils {
	import flash.external.ExternalInterface;
	
	
	public class StringUtil {
		
		public static const REGEXP_TRIM					:RegExp = /^\s+|\s+$/g;
		public static const REGEXP_URL_ENCODING_SAFE	:RegExp = /(["<>\\\^\[\]'\+\$,])+/gi;
		public static const REGEXP_LEADING_ZEROES		:RegExp = /^0+/g;
		public static const REGEXP_DOUBLE_SPACES		:RegExp = /[ \t]+/g;
		public static const REGEXP_VARNAME_SEGMENTS		:RegExp = /[A-Z]?[a-z]*/g;
		public static const REGEXP_NUMBER				:RegExp = /[0-9]+(?:\.[0-9]*)?/g;
		public static const REGEXP_DATE_TIME			:RegExp = /\d{1,2}\W\d{1,2}\W\d{4}\s*\d{1,2}\W\d{2}(\W\d{2})?\s*(?:am|AM|pm|PM)?/g; //"MM-DD-YYYY HH:NN:SS"
		public static const REGEXP_DATE_TIME_EXT		:RegExp = /(?P<day>\d{1,2})\W(?P<month>\d{1,2})\W(?P<year>\d{4})\s*(?P<hours>\d{1,2})\W(?P<minutes>\d{2})(\W(?P<seconds>\d{2}))?\s*(?P<period>(?:am|AM|pm|PM)?)/g;
		
		public static function trim(input:String):String {
			return input.replace(REGEXP_TRIM, "");
		}
		
		private function isURLEncodingSafe(input:String):Boolean {
			return REGEXP_URL_ENCODING_SAFE.test(input);
		}
		
		public static function splitAtLength(value:String, length:uint):String {
			var numRows:uint = Math.ceil(value.length / length);
			var result:String = "";
			for (var i:uint=0; i<numRows; i++) {
				result += value.substr(length * i, length) + ((i == numRows - 1) ? "" : "\n");
			}
			return result;
		}
		
		public static function removeZeroesAtBegin(input:String):String {
			return input.replace(REGEXP_LEADING_ZEROES, "");
		}
		
		public static function removeDoubleSpaces(input:String):String {
			return input.replace(REGEXP_DOUBLE_SPACES, " ");
		}
		
		/**
		 * camelCaseName string to UPPER_CASE_NAME
		 */
		public static function camelToUpper(name:String):String {
			var output:String = "";
			
			var segments:Array = name.match(REGEXP_VARNAME_SEGMENTS);
			for (var i:uint=0; i<segments.length; i++) {
				output += String(segments[i]).toUpperCase();
				output += (i < segments.length-1) ? "_" : "";
			}
			
			return output;
		}
		
		public static function getCurrencySymbol(value:String):String {
			switch (value) {
				case "EUR": return "€";
				case "GBP": return "£";
				case "USD": return "$";
				case "JPY": return "¥";
				/* etc. */
				default: return value;
			}
		}
		
		public static function YYMMDDtoDate(value:String):Date {
			var date:Date = new Date();
			
			var century:String = date.getFullYear().toString().substr(0, 2)
			var year:Number = parseInt(century + value.substr(0, 2));
			var month:Number = parseInt(value.substr(2, 2))-1;
			var day:Number = parseInt(value.substr(4, 2));
			
			date.setFullYear(year, month, day);
			return date;
		}
		
		public static function CCYYMMDDtoDate(value:String):Date {
			var date:Date = new Date();
			
			var year:Number = parseInt(value.substr(0, 4));
			var month:Number = parseInt(value.substr(4, 2))-1;
			var day:Number = parseInt(value.substr(6, 2));
			
			date.setFullYear(year, month, day);
			return date;
		}
		
		public static function getURLParams():Object {
			var pageURL:String = ExternalInterface.call('window.location.href.toString');
			if (pageURL != null) {
				var index:int = pageURL.lastIndexOf("#");
				
				if (index > -1) {
					var params:Array = pageURL.substr(index+1).split("&");
					var fragment:Object = {};
					var arg:String;
					var prop:String;
					var value:String;
					
					for (var i:uint=0; i<params.length; i++) {
						arg = params[i] as String;
						prop = arg.substr(0, arg.indexOf("="));
						value = arg.substr(arg.indexOf("=")+1);
						fragment[prop] = value;
					}
					
					return fragment;
				}
			}
			return null;
		}
		
	}
}