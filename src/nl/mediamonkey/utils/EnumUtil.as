package nl.mediamonkey.utils {
	
	import flash.utils.describeType;
	
	public class EnumUtil {
		
		public static const ACCESSOR:String = "accessor";
		public static const CONSTANT:String = "constant";
		
		public static function hasName(classType:Class, name:String, nodeType:String="accessor"):Boolean {
			if (nodeType != ACCESSOR && nodeType != CONSTANT) return false;
			
			var description:XML = describeType(classType);
			var nodeList:XMLList = description.child(nodeType);
			if (!nodeList || nodeList.length() == 0) return false;
			
			for each (var node:XML in nodeList) {
				if (node.@name == name) return true;
			}
			
			return false;
		}
		
		public static function hasValue(classType:Class, value:*, nodeType:String="accessor"):Boolean {
			if (nodeType != ACCESSOR && nodeType != CONSTANT) return false;
			
			var description:XML = describeType(classType);
			var nodeList:XMLList = description.child(nodeType);
			if (!nodeList || nodeList.length() == 0) return false;
			
			for each (var node:XML in nodeList) {
				if (classType[node.@name] == value) return true;
			}
			
			return false;
		}
		
		public static function getNames(classType:Class, nodeType:String="accessor"):Array {
			var collection:Array = [];
			
			if (nodeType != ACCESSOR && nodeType != CONSTANT) return collection;
			
			var description:XML = describeType(classType);
			var nodeList:XMLList = description.child(nodeType);
			if (!nodeList || nodeList.length() == 0) return collection;
			
			for each (var node:XML in nodeList) {
				collection.push(node.@name);
			}
			
			return collection;
		}
		
		public static function getValues(classType:Class, nodeType:String="accessor"):Array {
			var collection:Array = [];
			
			if (nodeType != ACCESSOR && nodeType != CONSTANT) return collection;
			
			var description:XML = describeType(classType);
			var nodeList:XMLList = description.child(nodeType);
			if (!nodeList || nodeList.length() == 0) return collection;
			
			for each (var node:XML in nodeList) {
				collection.push(classType[node.@name]);
			}
			
			return collection;
		}
		
		public static function getNameValueArray(classType:Class, nodeType:String="accessor"):Array {
			var collection:Array = [];
			
			if (nodeType != ACCESSOR && nodeType != CONSTANT) return collection;
			
			var description:XML = describeType(classType);
			var nodeList:XMLList = description.child(nodeType);
			if (!nodeList || nodeList.length() == 0) return collection;
			
			for each (var node:XML in nodeList) {
				if (node.@access == "readwrite")
					collection[node.@name] = classType[node.@name];
			}
			
			return collection;
		}

	}
}