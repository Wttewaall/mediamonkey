package nl.mediamonkey.behaviors.animationBehaviors {
	
	import flash.display.InteractiveObject;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.utils.getTimer;
	
	import nl.mediamonkey.behaviors.Behavior;
	
	public class RandomFrameBehavior extends Behavior {
		
		public var startFrame		:uint = 1;
		
		protected var currentTime	:uint;
		protected var nextTime		:uint;
		
		// ---- getters & setters ----
		
		private var _clip			:MovieClip;
		private var _minWaitTime	:Number = 4000;
		private var _maxWaitTime	:Number = 5000;
		
		public function get clip():MovieClip {
			return _clip ||= target as MovieClip;
		}
		
		public function get minWaitTime():Number {
			return _minWaitTime;
		}
		
		public function set minWaitTime(value:Number):void {
			_minWaitTime = value;
			setWaitTime();
		}
		
		public function get maxWaitTime():Number {
			return _maxWaitTime;
		}
		
		public function set maxWaitTime(value:Number):void {
			_maxWaitTime = value;
			setWaitTime();
		}
		
		// ---- constructor ----
		
		public function RandomFrameBehavior(target:InteractiveObject) {
			super(target);
			
			if (startFrame == 0) startFrame = clip.currentFrame;
			clip.gotoAndStop(startFrame);
			
			currentTime = getTimer();
			setWaitTime();
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
				clip.gotoAndStop(randomFrame());
				setWaitTime();
			}
		}
		
		// ---- protected methods ----
		
		protected function randomFrame():int {
			var frame:int = clip.currentFrame;
			if (clip.totalFrames == 1) return frame;
			
			while (frame == clip.currentFrame) {
				frame = Math.ceil(Math.random() * clip.totalFrames);
			}
			
			return frame;
		}
		
		protected function setWaitTime():void {
			nextTime = currentTime + minWaitTime + Math.random() * (maxWaitTime - minWaitTime);
		}
		
	}
	
}
