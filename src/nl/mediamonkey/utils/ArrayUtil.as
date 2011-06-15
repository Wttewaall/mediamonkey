package nl.mediamonkey.utils {
	
	public class ArrayUtil {
		
		public static function getItemIndex(array:Array, item:Object):int {
			var i:int = array.length;
			while (i--) if (array[i] == item) return i;
			return -1;           
		}
		
		public static function getTypeIndex(array:Array, type:Class):int {
			var i:int = array.length;
			while (i--) if (array[i] is type) return i;
			return -1;
		}
		
		public static function containsType(array:Array, type:Class):Boolean {
			for each (var item:Object in array) if (item is type) return true;
			return false;
		}
		
		public static function containsItem(array:Array, item:*):Boolean {
			for each (var element:* in array) if (element == item) return true;
			return false;
		}
		
		public static function containsItems(array:Array, compareArray:Array):Boolean {
			var result:Boolean = true;
			for each (var element:* in array) result &&= (compareArray.indexOf(element) > -1);
			return result;
		}
		
		public static function replaceAt(array:Array, item:*, index:int):Array {
			var tmp:Array = array.concat();
			tmp.splice(index, 1, item);
			return tmp;
		}
		
		public static function removeAt(array:Array, index:int):Array {
			var tmp:Array = array.concat();
			tmp.splice(index, 1);
			return tmp;
		}
		
		public static function add(array:Array, item:*):Array {
			var tmp:Array = array.concat();
			tmp.push(item);
			return tmp;
		}
		
		public static function removeItems(items:Array, fromArray:Array):void {
			for (var i:int=0; i<items.length; i++) {
				var index:int = getItemIndex(fromArray, items[i]);
				if (index > -1) fromArray.splice(index, 1);
			}
		}
	}
}