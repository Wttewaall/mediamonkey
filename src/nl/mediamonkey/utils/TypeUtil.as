package nl.mediamonkey.utils {
	
	import flash.utils.getDefinitionByName;
	
	import mx.collections.ArrayCollection;
	
	public final class TypeUtil {
		
		public static const hexPattern		:RegExp = /(\#|0x|0X)([0-9a-fA-F]{6})/;
		public static const valuePattern	:RegExp = /(".*?")|(?:'.*?')|[#\w-\.\+]+/g;
		
		/**
	     * Converts a variable from a String to the best suited type for the variable.
	     *
		 * "flash.events.Event" -> Event object
		 * "flash.events::Event" -> Event object
		 * "flash.events.Event.COMPLETE" -> "complete" string
		 * "flash.events::Event.COMPLETE" -> "complete" string
		 * 
	     * @param value the value to convert
	     * @return the converted value, or the input string if a conversion was not possible.
	     */
		public static function stringToValue(value:String, forceType:Class=null):* {
			
			if (forceType != null) {
				if (forceType == Number) return forceType(parseFloat(value));
				if (forceType == int || forceType == uint) return forceType(parseInt(value));
				if (forceType == Boolean) return (value.toLowerCase() == "true");
				if (forceType == String) return forceType(value);
			}
			
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
		
		public static function stringToValueArray(value:String):Array {
			var valueArray:Array = [];
			
			// retrieve string values
			var stringValues:Array = value.match(valuePattern);
			
			// convert every string to the correct type
			for (var i:int=0; i<stringValues.length; i++) {
				valueArray.push( stringToValue(stringValues[i] as String) );
			}
			
			return valueArray;
		}
		
		public static function stringToValueArrayCollection(value:String):ArrayCollection {
			return new ArrayCollection( stringToValueArray(value) );
		}
	}
}
