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
		
	}
}