package nl.mediamonkey.utils {
	
	public class URIUtil {
		
		// http://xkr.us/articles/javascript/encode-compare/
		
		private static const escapeIgnoreArray:Array = ["@", "*", "/", "+"];
		private static const encodeURIIgnoreArray:Array = ["~", "!", "@", "#", "$", "&", "*", "(", ")", "=", ":", "/", ",", ";", "?", "+", "'"];
		private static const encodeURIComponentIgnoreArray:Array = ["~", "!", "*", "(", ")", "'"];
		
		private static const chars:Array = [
			"%", " ", "!", "<", ">", "#", "(", ")", "{", "}",
			"|", "\\", "^", "~", "[", "]", "`", ",", ";", "/",
			"?", ":", "@", "=", "&", "$", "\'", "\"", "+"
		];
		
		private static const codes:Array = [
			"%25", "%20", "%21", "%3C", "%3E", "%23", "%28", "%29", "%7B", "%7D",
			"%7C", "%5C", "%5E", "%7E", "%5B", "%5D", "%60", "%2C", "%3B", "%2F",
			"%3F", "%3A", "%40", "%3D", "%26", "%24", "%27", "%22", "%2B"
		];
		
		/** will not encode: @/*+ **/
		public static function escape(str:String):String {			
			return encode(str, escapeIgnoreArray, false);
		}
		
		/** will not decode: @/*+ **/
		public static function unescape(str:String):String {	
			return encode(str, escapeIgnoreArray, true);
		}
		
		/** will not encode: ~!@#$&*()=:/,;?+' **/
		public static function encodeURI(uri:String):String {	
			return encode(uri, encodeURIIgnoreArray, false);
		}
		
		/** will not decode: ~!@#$&*()=:/,;?+' **/
		public static function decodeURI(uri:String):String {	
			return encode(uri, encodeURIIgnoreArray, true);
		}
		
		/** will not encode: ~!*()' **/
		public static function encodeURIComponent(uri:String):String {	
			return encode(uri, encodeURIComponentIgnoreArray, false);
		}
		
		/** will not decode: ~!*()' **/
		public static function decodeURIComponent(uri:String):String {	
			return encode(uri, encodeURIComponentIgnoreArray, true);
		}
		
		private static function encode(str:String, ignore:Array, inverse:Boolean):String {
			var fromChars:Array = inverse ? codes : chars;
			var toChars:Array = inverse ? chars : codes;
			
			var pattern:String;
			
			for (var i:int=0; i<chars.length; i++) {
				
				if (ignore.indexOf(chars[i]) == -1 && str.indexOf(chars[i]) > -1) {
					
					pattern = String(fromChars[i]);
					// escape single character for use in regexp pattern (it may choke on a "|" )
					if (pattern.length == 1) pattern = "\\"+pattern;
					
					str = str.replace(new RegExp(pattern, "gm"), String(toChars[i]));
				}
			}
			
			return str;
		}
		
		// ----
		
		public static function test():void {
			var url:String = "https://localhost:2700/#bla/?value=~!@#$&*()=:/,;?+'";
			var escaped:String = "https%3A//localhost%3A2700/%2523bla/%3Fvalue%3D%7E%2521@%2523%24%26*%28%29%3D%3A/%2C%3B%3F+%27";
			
			trace(escape(url));
			trace(unescape(escaped));
			trace(encodeURI(url));
			trace(decodeURI(escaped));
			trace(encodeURIComponent(url));
			trace(decodeURIComponent(escaped));
		}
		
	}
	
}