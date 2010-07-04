package nl.mediamonkey.utils.data {
	
	public class Cursor {
		
		public var cursorIcon		:Class;
		public var priority			:int;
		public var offsetX			:Number;
		public var offsetY			:Number;
		public var blendMode		:String;
		
		public function Cursor(cursorIcon:Class, priority:int=2, offsetX:Number=0, offsetY:Number=0, blendMode:String="normal") {
			this.cursorIcon = cursorIcon;
			this.priority = priority;
			this.offsetX = offsetX;
			this.offsetY = offsetY;
			this.blendMode = blendMode;
		}
		
		public function toString():String {
			return "[CursorVO {"+cursorIcon+", "+priority+", "+offsetX+", "+offsetY+", "+blendMode+"}]";
		}

	}
}