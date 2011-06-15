package nl.mediamonkey.utils.data {
	
	public class Cursor {
		
		public var cursorIcon		:Class;
		public var priority			:int;
		public var offsetX			:Number;
		public var offsetY			:Number;
		public var blendMode		:String;
		public var hideMouse		:Boolean;
		
		public function Cursor(cursorIcon:Class, priority:int=2, offsetX:Number=0, offsetY:Number=0, blendMode:String="normal", hideMouse:Boolean=true) {
			this.cursorIcon = cursorIcon;
			this.priority = priority;
			this.offsetX = offsetX;
			this.offsetY = offsetY;
			this.blendMode = blendMode;
			this.hideMouse = hideMouse;
		}
		
		public function toString():String {
			return "[Cursor {"+cursorIcon+", "+priority+", "+offsetX+", "+offsetY+", "+blendMode+", "+hideMouse+"}]";
		}

	}
}