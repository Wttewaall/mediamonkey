package nl.mediamonkey.utils {
	
	public class StringUtil {
		
		public static function trim(input:String):String {
			var pattern:RegExp = /^\s+|\s+$/g;
			return input.replace(pattern, "");
		}
		
		private function isURLEncodingSafe(input:String):Boolean {
			var pattern:RegExp = /(["<>\\\^\[\]'\+\$,])+/gi;
			return pattern.test(input);
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
			var pattern:RegExp = /^0+/g;
			return input.replace(pattern, "");
		}
		
		public static function removeDoubleSpaces(input:String):String {
			var pattern:RegExp = /[ \t]+/g; // ignore newline, so don't use \s
			return input.replace(pattern, " ");
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
		
	}
}