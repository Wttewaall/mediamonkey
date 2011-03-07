package nl.mediamonkey.utils {
	
	import flash.utils.Dictionary;
	
	public class DictionaryUtil {
		
		public static function getKeys(dict:Dictionary):Array {
			var keys:Array = new Array();
			for (var key:Object in dict) keys.push(key);
			return keys;
		}
					
		public static function getValues(dict:Dictionary):Array {
			var values:Array = new Array();
			for each (var value:Object in dict) values.push(value);
			return values;
		}
		
		public static function getLength(dict:Dictionary):uint {
			return getKeys(dict).length;
		}
		
		public static function containsValue(dict:Dictionary, value:Object):Boolean {
			for (var key:* in dict) {
				if (dict[key] === value) return true;
			}
			return false;
		}
		
		public static function containsKey(dict:Dictionary, key:Object):Boolean {
			for (var k:* in dict) {
				if (k == key) return true;
			}
			return false;
		}
		
		public static function keyFromValue(dict:Dictionary, value:*):* {
			for (var key:* in dict) {
				if (dict[key] === value) return key;
			}
			return null;
		}
		
		public static function valueFromKey(dict:Dictionary, key:*):* {
			return dict[key];
		}
		
		public static function difference(d1:Dictionary, d2:Dictionary):Dictionary {
			var result:Dictionary = new Dictionary;
			var prop:String;
			
			for (prop in d1) if (!containsValue(d2, d1[prop])) result[prop] = d1[prop];
			for (prop in d2) if (!containsValue(d1, d2[prop])) result[prop] = d2[prop];
			
			return result;
		}
		
	}
}