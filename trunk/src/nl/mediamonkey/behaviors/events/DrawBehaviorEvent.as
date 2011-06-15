package nl.mediamonkey.behaviors.events {
	
	import flash.events.Event;
	
	public class DrawBehaviorEvent extends Event {
		
		public static const PEN_DOWN		:String = "penDown";
		public static const PEN_UP			:String = "penUp";
		public static const DRAW			:String = "draw";
		
		public var x:Number;
		public var y:Number;
		
		public function DrawBehaviorEvent(type:String, x:Number=NaN, y:Number=NaN) {
			super(type, false, false);
			this.x = x;
			this.y = y;
		}
		
	}
}