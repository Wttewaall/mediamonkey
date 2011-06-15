package nl.mediamonkey.behaviors.events {
	
	import flash.events.Event;
	
	import nl.mediamonkey.behaviors.IBehavior;
	
	public class MouseBehaviorEvent extends Event {
		
		public static const MOUSE_DOWN		:String = "mouseDown";
		public static const MOUSE_UP		:String = "mouseUp";
		public static const MOUSE_MOVE		:String = "mouseMove";
		public static const DRAG_START		:String = "dragStart";
		public static const DRAG_MOVE		:String = "dragMove";
		public static const DRAG_END		:String = "dragEnd";
		
		public var behavior	:IBehavior;
		public var oldX		:Number;
		public var oldY		:Number;
		
		public function MouseBehaviorEvent(type:String, behavior:IBehavior, bubbles:Boolean=false, cancelable:Boolean=false, oldX:Number=NaN, oldY:Number=NaN) {
			super(type, bubbles, cancelable);
			
			this.behavior = behavior;
			this.oldX = oldX;
			this.oldY = oldY;
		}
		
	}
}