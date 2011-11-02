package nl.mediamonkey.behaviors.animationBehaviors {
	
	import fl.motion.easing.*;
	
	import flash.events.Event;
	import flash.geom.Point;
	import flash.display.InteractiveObject;
	
	import nl.mediamonkey.behaviors.Behavior;
	
	public class FadeBehavior extends Behavior {
		
		public var startValue	:Number;
		public var fadeRange	:Number = 1;
		public var duration		:Number = 20; // in frames
		public var pingPong		:Boolean;
		public var easeFunction	:Function;
		
		protected var stepper	:CursorStepper;
		
		public function FadeBehavior(target:InteractiveObject, duration:Number, pingPong:Boolean=true, easeFunction:Function=null) {
			super(target);
			
			this.startValue = target.alpha;
			this.duration = duration || 24;
			this.pingPong = pingPong;
			this.easeFunction = easeFunction || Quadratic.easeInOut;
			
			stepper = new CursorStepper(0, duration, (pingPong ? CursorStepper.PING_PONG : CursorStepper.LINEAR));
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
			target.alpha = easeFunction(stepper.next(), fadeRange-startValue, fadeRange, 20);
		}

	}
	
}
