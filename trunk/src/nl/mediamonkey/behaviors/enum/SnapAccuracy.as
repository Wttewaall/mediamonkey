package nl.mediamonkey.behaviors.enum {
	
	import mx.collections.ArrayCollection;
	
	public final class SnapAccuracy {
		
		public static const CLOSE		:Number = 2;
		public static const NORMAL		:Number = 5;
		public static const DISTANT		:Number = 10;
		public static const ALWAYS		:Number = Infinity;
		
		private static var _data		:ArrayCollection;
		
		public static function get data():ArrayCollection {
			if (!_data) _data = new ArrayCollection(buildData());
			return _data;
		}
		
		protected static function buildData():Array {
			return [
				{label:"snap close", data:CLOSE},
				{label:"snap normal", data:NORMAL},
				{label:"snap distant", data:DISTANT},
				{label:"snap always", data:ALWAYS}
			]
		}
		
	}
}