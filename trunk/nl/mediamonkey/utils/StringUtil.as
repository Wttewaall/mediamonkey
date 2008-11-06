package nl.mediamonkey.utils {
	
	public class StringUtil {
		
		public static function trim(input: String): String {
			var pattern:RegExp = /^\s+|\s+$/g;
			return input.replace(pattern, "");
		}
		
	}
}