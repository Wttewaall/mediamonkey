package nl.mediamonkey.behaviors.events {
	
	import flash.events.Event;
	
	public class SnapEvent extends Event {
		
		public static const SNAP_ALL			:String = "snapAll";
		public static const SNAP_HORIZONTAL		:String = "snapHorizontal";
		public static const SNAP_VERTICAL		:String = "snapVertical";
		
		public var snapX:Number;
		public var snapY:Number;
		
		public function SnapEvent(type:String, snapX:Number, snapY:Number, bubbles:Boolean=false, cancelable:Boolean=false) {
			super(type, bubbles, cancelable);
			this.snapX = snapX;
			this.snapY = snapY;
		}
		
	}
}