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
		
		public static function contains(dict:Dictionary, value:Object):Boolean {
			for (var key:Object in dict) {
				if (dict[key] == value) return true;
			}
			return false;
		}
		
		public static function keyFromValue(dict:Dictionary, value:Object):Object {
			for (var key:Object in dict) {
				if (dict[key] == value) return key;
			}
			return null;
		}
		
		public static function valueFromKey(dict:Dictionary, key:String):Object {
			return dict[key];
		}
		
	}
}