package nl.mediamonkey.utils {
	
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.MouseEvent;
	
	/**
	 * Static class that fires an event when the SWF has mouseover or not.
	 * Original idea: http://www.bigspaceship.com/blog/labs/as3-optimization-tip
	 * 
	 * usage:
	 * MouseLeaveUtil.initialize(this); // where this is preferably the root or document class
	 * MouseLeaveUtil.addEventListener(MouseLeaveUtil.ENABLE, enableHandler);
	 * MouseLeaveUtil.addEventListener(MouseLeaveUtil.DISABLE, disableHandler);
	 * 
	 * private function enableHandler(event:Event):void {
	 * 		trace("enable the application");
	 * }
	 * 
	 * private function disableHandler(event:Event):void {
	 * 		trace("disable the application");
	 * }
	 */
	
	[Event(name="disable", type="nl.mediamonkey.utils.MouseLeaveUtil")]
	[Event(name="enable", type="nl.mediamonkey.utils.MouseLeaveUtil")]
	
	public class MouseLeaveUtil implements IEventDispatcher {
		
		public static const DISABLE			:String = "disable";
		public static const ENABLE			:String = "enable";
		
		private static var target			:DisplayObject;
		private static var dispatcher		:EventDispatcher;
		
		// ---- constructor; which, as a Singleton, cannot be instantiated from ----
		
		public function MouseLeaveUtil(lock:SingletonLock) {
			if (lock == null) throw new ArgumentError("MouseLeaveUtil is a static class and cannot be instantiated.");
		}
		
		// ---- public static methods ----
		
		public static function initialize(target:DisplayObject):void {
			if (target == null) throw new ArgumentError("Target must be of type DisplayObject and cannot be null.");
			MouseLeaveUtil.target = target;
			dispatcher = new EventDispatcher();
			
			if (target.stage) {
				target.stage.addEventListener(Event.MOUSE_LEAVE, leaveStageHandler, false, 0, true);
				
			} else {
				// if stage is not yet available, wait for this event to trigger
				target.addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
			}
		}
		
		/** add listeners directly to the static class */
		public static function addEventListener(type:String, listener:Function, useCapture:Boolean=false, priority:int=0, useWeakReference:Boolean=false):void {
			dispatcher.addEventListener(type, listener, useCapture, priority, useWeakReference);
		}
		
		public static function removeEventListener(type:String, listener:Function, useCapture:Boolean=false):void {
			dispatcher.addEventListener(type, listener, useCapture);
		}
		
		// ---- event handlers ----
		
		private static function addedToStageHandler(event:Event):void {
			target.removeEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
			target.stage.addEventListener(Event.MOUSE_LEAVE, leaveStageHandler, false, 0, true);
		}
		
		private static function leaveStageHandler(event:Event):void {
			target.stage.addEventListener(MouseEvent.MOUSE_MOVE, returnToStageHandler, false, 0, true);
			dispatcher.dispatchEvent(new Event(DISABLE));
		}
		
		private static function returnToStageHandler(event:MouseEvent):void {
			target.stage.removeEventListener(MouseEvent.MOUSE_MOVE, returnToStageHandler);
			dispatcher.dispatchEvent(new Event(ENABLE));
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