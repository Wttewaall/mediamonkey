package nl.mediamonkey.utils {
	
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.KeyboardEvent;
	import flash.text.TextField;
	import flash.utils.getTimer;
	
	/**
	 * Static class that an event when a certain (hard-coded) keyword is typed in.
	 * 
	 * usage:
	 * EasterEgg.initialize(this); // where this is preferably the root or document class
	 * EasterEgg.addEventListener(EasterEgg.EASTER_EGG, easterEggHandler);
	 * 
	 * private function easterEggHandler(event:Event):void {
	 * 		trace("I made this!");
	 * }
	 */
	
	[Event(name="easterEgg", type="nl.mediamonkey.utils.EasterEgg")]
	
	public class EasterEgg implements IEventDispatcher {
		
		public static const EASTER_EGG		:String = "easterEgg";
		
		private static const keyword		:String = "mediamonkey";
		private static const timeout		:uint = 1000;
		
		private static var target			:DisplayObject;
		private static var dispatcher		:EventDispatcher;
		private static var cursor			:uint;
		private static var previousTime		:uint;
		
		// ---- constructor; which, as a Singleton, cannot be instantiated from ----
		
		public function EasterEgg(lock:SingletonLock) {
			if (lock == null) throw new ArgumentError("EasterEgg is a static class and cannot be instantiated.");
		}
		
		// ---- public static methods ----
		
		public static function initialize(target:DisplayObject):void {
			if (target == null) throw new ArgumentError("Target must be of type DisplayObject and cannot be null.");
			EasterEgg.target = target;
			dispatcher = new EventDispatcher();
			target.addEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler);
		}
		
		/** add listeners directly to the static class */
		public static function addEventListener(type:String, listener:Function, useCapture:Boolean=false, priority:int=0, useWeakReference:Boolean=false):void {
			if (!dispatcher) throw new Error("You'll need to initialize the EasterEgg class before adding a listener.");
			dispatcher.addEventListener(type, listener, useCapture, priority, useWeakReference);
		}
		
		/* why would you need these?
		
		public static function removeEventListener(type:String, listener:Function, useCapture:Boolean=false):void {
			dispatcher.addEventListener(type, listener, useCapture);
		}
		
		public static function dispatchEvent(event:Event):Boolean {
			return dispatcher.dispatchEvent(event);
		}
		
		public static function hasEventListener(type:String):Boolean {
			return dispatcher.hasEventListener(type);
		}
		
		public static function willTrigger(type:String):Boolean {
			return dispatcher.willTrigger(type);
		}
		*/
		
		// ---- event handlers ----
		
		private static function keyDownHandler(event:KeyboardEvent):void {
			// ignore when typing in a TextField
			if (target.stage && target.stage.focus is TextField) {
				cursor = 0;
				return;
			}
			
			// timeout (silently on next keystroke)
			var currentTime:uint = getTimer();
			if (cursor > 0 && currentTime - previousTime >= timeout) {
				cursor = 0;
			}
			previousTime = currentTime;
			
			// validate char at cursor
			if (!charAtCursor(String.fromCharCode(event.charCode)) && cursor > 0) {
				cursor = 0; // set cursor to 0, and try once more
				charAtCursor(String.fromCharCode(event.charCode));
			}
		}
		
		private static function charAtCursor(char:String):Boolean {
			if (char == keyword.charAt(cursor)) {
				if (cursor == keyword.length - 1) {
					dispatcher.dispatchEvent(new Event(EASTER_EGG));
					cursor = 0;
				} else {
					cursor++;
				}
				return true;
			}
			return false;
		}
		
		// ---- null methods ----
		
		/**
		 * These were added to facilitate adding/removing a listener to this static class as any normal IEventDispatcher
		 */
		
		public function addEventListener(type:String, listener:Function, useCapture:Boolean=false, priority:int=0, useWeakReference:Boolean=false):void {}
		public function removeEventListener(type:String, listener:Function, useCapture:Boolean=false):void {}
		public function dispatchEvent(event:Event):Boolean { return false }
		public function hasEventListener(type:String):Boolean { return false }
		public function willTrigger(type:String):Boolean { return false }
		
	}
}

class SingletonLock {}