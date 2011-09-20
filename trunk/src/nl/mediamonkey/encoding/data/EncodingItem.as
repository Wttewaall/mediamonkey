package nl.mediamonkey.encoding.data {
	
	import flash.display.BitmapData;
	import flash.utils.ByteArray;
	
	public class EncodingItem {
		
		public var bitmapData	:BitmapData;
		public var width		:uint;
		public var height		:uint;
		public var quality		:int = 100;
		public var contentType	:String;
		public var bytes		:ByteArray;
		public var base64		:String;
		public var name			:String; // optional
		
		// ---- constructor ----
		
		public function EncodingItem(width:uint, height:uint, contentType:String=null) {
			this.width = width;
			this.height = height;
			this.contentType = contentType;
		}
		
	}
}