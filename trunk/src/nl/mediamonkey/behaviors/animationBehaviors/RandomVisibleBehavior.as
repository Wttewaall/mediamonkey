package nl.mediamonkey.behaviors.animationBehaviors {
	
	import flash.events.Event;
	import flash.geom.Point;
	import flash.display.InteractiveObject;
	
	import nl.mediamonkey.behaviors.Behavior;
	import flash.utils.getTimer;
	
	public class RandomVisibleBehavior extends Behavior {
		
		public var startVisible		:Boolean = false;
		public var minWaitTime		:Number = 1000;
		public var maxWaitTime		:Number = 3000;
		public var minVisibleTime	:Number = 30;
		public var maxVisibleTime	:Number = 150;
		
		protected var currentTime	:uint;
		protected var nextTime		:uint;
		protected var visible		:Boolean;
		
		// ---- constructor ----
		
		public function RandomVisibleBehavior(target:InteractiveObject) {
			super(target);
			
			target.visible = visible = startVisible;
			
			currentTime = getTimer();
			if (visible) setVisibleTime();
			else setWaitTime();
		}
		
		// ---- event handlers ----
		
		override protected function addListeners(target:InteractiveObject):void {
			super.addListeners(target);
			target.addEventListener(Event.ENTER_FRAME, enterFrameHandler, false, 0, true);
		}
		
		override protected function removeListeners(target:InteractiveObject):void {
			super.removeListeners(target);
			target.removeEventListener(Event.ENTER_FRAME, enterFrameHandler);
		}
		
		protected function enterFrameHandler(event:Event):void {
			currentTime = getTimer();
			
			if (nextTime <= currentTime) {
				visible = !visible;
				
				if (visible && minWaitTime > 0 && maxWaitTime > 0) {
					setVisibleTime();
					
				} else {
					setWaitTime();
				}
				
				target.visible = visible;
			}
		}
		
		// ---- protected methods ----
		
		protected function setWaitTime():void {
			nextTime = currentTime + minWaitTime + Math.random() * (maxWaitTime - minWaitTime);
		}
		
		protected function setVisibleTime():void {
			nextTime = currentTime + minVisibleTime + Math.random() * (maxVisibleTime - minVisibleTime);
		}

	}
	
}