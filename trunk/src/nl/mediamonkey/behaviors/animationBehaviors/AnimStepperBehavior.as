/**
maximum frameRate is swf frameRate (or use a timer instead of enterFrame event)
**/

package nl.mediamonkey.behaviors.animationBehaviors {
	
	import flash.display.InteractiveObject;
	import flash.display.MovieClip;
	import flash.events.Event;
	
	import nl.mediamonkey.behaviors.Behavior;
	
	public class AnimStepperBehavior extends Behavior {
		
		// mode enums
		public static const LINEAR			:String = CursorStepper.LINEAR;
		public static const PING_PONG		:String = CursorStepper.PING_PONG;
		public static const ALTERNATING		:String = CursorStepper.ALTERNATING;
		
		// variables
		protected var stepper			:CursorStepper = new CursorStepper(0, 0);
		protected var rate				:uint;
		protected var frame				:uint;
		protected var frameRateChange	:Boolean; // rate will be set in the first enterFrame
		
		// ---- getters & setters ----
		
		private var _clip			:MovieClip;
		private var _startFrame		:uint = 1;
		private var _direction		:int = 1;
		private var _frameRate		:Number = 24;
		
		public function get clip():MovieClip {
			return _clip ||= target as MovieClip;
		}
		
		public function get startFrame():uint {
			return stepper.startPosition + 1;
		}
		
		// 1-base index
		public function set startFrame(value:uint):void {
			stepper.startPosition = value - 1;
		}
		
		public function get mode():String {
			return stepper.mode;
		}
		
		public function set mode(value:String):void {
			stepper.mode = value;
		}
		
		public function get direction():int {
			return stepper.direction;
		}
		
		public function set direction(value:int):void {
			stepper.direction = value;
		}
		
		public function set frameRate(value:Number):void {
			_frameRate = value;
			frameRateChange = true;
		}
		
		public function get frameRate():Number {
			return _frameRate;
		}
		
		// ---- constructor ----
		
		public function AnimStepperBehavior(target:InteractiveObject, frameRate:Number=24, mode:String="linear", direction:int=1) {
			super(target);
			
			if (target is MovieClip == false)
				throw new TypeError("target must be of type MovieClip");
			
			this.frameRate = frameRate;
			this.mode = mode;
			this.direction = direction;
			
			clip.stop();
		}
		
		// ---- overrides & event handlers ----
		
		override public function set target(value:InteractiveObject):void {
			super.target = value;
			
			// next frame the cursor will be correct
			if (startFrame > 0) stepper.cursor = startFrame - direction;
			else stepper.cursor = clip.currentFrame - direction;
			
			stepper.length = clip.totalFrames;
			
			frameRateChange = true;
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
			if (enabled) update();
		}
		
		// ---- public methods ----
		
		public function update():void {
			
			// calculate rate in frames
			if (frameRateChange) {
				if (target.root) rate = Math.ceil(target.root.loaderInfo.frameRate / _frameRate);
				frameRateChange = false;
			}
			
			// update every n-th frame
			if (++frame % rate == 0) {
				frame = 0;
				
				clip.gotoAndStop(stepper.next() + 1);
			}
		}
		
	}
}