package nl.mediamonkey.behaviors.events {
	
	import flash.events.Event;
	
	public class MoveEvent extends Event {
		
		public static const MOVE			:String = "move";
		public static const DRAG_START		:String = "dragStart";
		public static const DRAG_MOVE		:String = "dragMove";
		public static const DRAG_END		:String = "dragEnd";
		
		public var oldX:Number;
		public var oldY:Number;
		
		public function MoveEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false, oldX:Number=NaN, oldY:Number=NaN) {
			super(type, bubbles, cancelable);
			this.oldX = oldX;
			this.oldY = oldY;
		}
		
	}
}