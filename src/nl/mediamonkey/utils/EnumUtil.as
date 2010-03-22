package nl.mediamonkey.utils {
	
	import flash.utils.describeType;
	
	public class EnumUtil {
		
		public static function hasConst(classType:Class, value:*):Boolean {
			var description:XML = describeType(classType);
			if (description.constant == undefined) return false;
			
			var constants:XMLList = description.constant as XMLList;
			var node:XML;
			
			for each (node in constants) {
				if (classType[node.@name] == value) return true;
			}
			
			return false;
		}
		
		public static function getConstNames(classType:Class, value:*):Array {
			var collection:Array = [];
			
			var description:XML = describeType(classType);
			if (description.constant == undefined) return [];
			
			var constants:XMLList = description.constant as XMLList;
			var node:XML;
			
			for each (node in constants) {
				collection.push(node.@name);
			}
			
			return collection;
		}
		
		public static function getConstValues(classType:Class, value:*):Array {
			var collection:Array = [];
			
			var description:XML = describeType(classType);
			if (description.constant == undefined) return [];
			
			var constants:XMLList = description.constant as XMLList;
			var node:XML;
			
			for each (node in constants) {
				collection.push(classType[node.@name]);
			}
			
			return collection;
		}
		
		public static function getConstArray(classType:Class, value:*):Array {
			var collection:Array = [];
			
			var description:XML = describeType(classType);
			if (description.constant == undefined) return [];
			
			var constants:XMLList = description.constant as XMLList;
			var node:XML;
			
			for each (node in constants) {
				collection[node.@name] = classType[node.@name];
			}
			
			return collection;
		}

	}
}