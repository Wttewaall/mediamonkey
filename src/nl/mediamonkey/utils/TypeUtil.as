package nl.mediamonkey.utils {
	
	import flash.utils.getDefinitionByName;
	
	public final class TypeUtil {
		
		protected static const hexPattern:RegExp = /(\#|0x|0X)([0-9a-fA-F]{1,6})/;
		
		/**
	     * Converts a variable from a String to the best suited type for the variable.
	     *
	     * @param value the value to convert
	     * @return the converted value, or the input string if a conversion was not possible.
	     */
		public static function fromString(value:String):* {
			
			// Boolean
			if (value.toLowerCase() == "true") return true;
			if (value.toLowerCase() == "false") return false;
			
			// Number, int or uint
			if (!isNaN(Number(value))) return Number(value);
			
			// Class
			try {
				var result:Object = getDefinitionByName(value);
				if (result != null) return result;
			} catch (e:Error) {};
			
			// Class with path
			if (value.indexOf(".") != -1) {
				var a:Array = value.split(".");
				var last:String = String(a.pop());
				
				try {
					result = getDefinitionByName(a.join("."));
				} catch (e:Error) {};
				
				if (result != null && result.hasOwnProperty(last)) {
					return result[last];
				}
			}
			
			// Hex value in string format
			if (hexPattern.test(value)) {
				return parseInt("0x"+value.replace(hexPattern, "$2"));
			}
			
			// String
			return value;
		}
	}
}
