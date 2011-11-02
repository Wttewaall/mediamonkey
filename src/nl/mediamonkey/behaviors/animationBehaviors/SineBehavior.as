package nl.mediamonkey.behaviors.animationBehaviors {
	
	import flash.events.Event;
	import flash.geom.Point;
	import flash.display.InteractiveObject;
	
	import nl.mediamonkey.behaviors.Behavior;
	
	public class SineBehavior extends Behavior {
		
		public var position		:Point;
		public var bobHRange	:Number = 5;
		public var bobHSpeed	:Number = 0.05;
		public var bobVRange	:Number = 5;
		public var bobVSpeed	:Number = 0.1;
		
		protected var frame		:uint = 0;
		
		public function SineBehavior(target:InteractiveObject) {
			super(target);
			
			position = new Point(target.x, target.y);
		}
		
		override protected function addListeners(target:InteractiveObject):void {
			super.addListeners(target);
			target.addEventListener(Event.ENTER_FRAME, enterFrameHandler, false, 0, true);
		}
		
		override protected function removeListeners(target:InteractiveObject):void {
			super.removeListeners(target);
			target.removeEventListener(Event.ENTER_FRAME, enterFrameHandler);
		}
		
		protected function enterFrameHandler(event:Event):void {
			if (frame++ >= uint.MAX_VALUE) frame = 0;
			target.x = position.x - bobHRange/2 + Math.sin(frame * bobHSpeed) * bobHRange;
			target.y = position.y - bobVRange/2 + Math.sin(frame * bobVSpeed) * bobVRange;
		}

	}
	
}
