package nl.mediamonkey.behaviors.data {
	
	import flash.display.DisplayObject;
	import flash.geom.Rectangle;
	
	import nl.mediamonkey.utils.DebugUtil;
	
	public class SnapResult {
		
		public static const LEFT		:String = "left";
		public static const RIGHT		:String = "right";
		public static const TOP			:String = "top";
		public static const BOTTOM		:String = "bottom";
		
		// ---- variables ----
		
		public var object		:DisplayObject;
		public var rect			:Rectangle;
		public var side			:String;
		
		// ---- getters & setters ----
		
		public function get value():Number {
			return rect[side];
		}
		
		// ---- constructor ----
		
		public function SnapResult() {
		}
		
		// ---- public methods ----
		
		public function setResult(object:DisplayObject, rect:Rectangle, side:String):void {
			DebugUtil.expect(side, LEFT, RIGHT, TOP, BOTTOM);
			
			this.object = object;
			this.rect = rect;
			this.side = side;
		}
		
	}
}