package nl.mediamonkey.invalidation {
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.utils.Dictionary;
	
	
	/**
	 * todo
	 *	. try using Object.watch to register a property and fire an invalidationEvent on change?
	 */
	
	[Event(name="invalidation", type="nl.mediamonkey.invalidation.InvalidatorEvent")]
	
	/**
	 * We make use of a DisplayObjectContainer (most basic class) to recieve Event.ENTER_FRAME events
	 * Otherwise we'd have to use a timer, which might run unsynchronized to the framerate
	 */
	public class Invalidator extends EventDispatcher {
		
		protected var invalidationObject		:Sprite;
		protected var invalidatedProperties		:Dictionary;
		protected var _invalidatePropertiesFlag	:Boolean;
		
		// ---- constructor ----
		
		public function Invalidator() {
			invalidationObject = new Sprite();
			invalidatedProperties = new Dictionary();
		}
		
		// ---- public methods ----
		
		/**
		 * You can invalidate on a specific property, which gives you te option to only update
		 * a very specific part of you application/model/state. You can also un-invalidate on a
		 * property by passing a false-value.
		 */
		public function invalidate(type:String="all", value:Boolean=true):void {
			if (value == true) {
				invalidatedProperties[type] = value;
				
			} else {
				delete invalidatedProperties[type];
			}
			
			var numInvalidProperties:uint = 0;
			for (var key:String in invalidatedProperties) {
				numInvalidProperties++;
			}
			
			setInvalidatePropertiesFlag(numInvalidProperties > 0);
		}
		
		/**
		 * This cancels all invalidated properties. No event will be fired.
		 */
		public function cancelInvalidation():void {
			setInvalidatePropertiesFlag(false);
		}
		
		/**
		 * Check with this method whether a property has been invalidated.
		 */
		public function isInvalid(type:String):Boolean {
			return (invalidatedProperties[type] == true);
		}
		
		// ---- protected methods ----
		
		protected function getInvalidatePropertiesFlag():Boolean {
			return _invalidatePropertiesFlag;
		}
		
		protected function setInvalidatePropertiesFlag(value:Boolean):void {
			if (_invalidatePropertiesFlag != value) {
				_invalidatePropertiesFlag = value;
				
				if (_invalidatePropertiesFlag == true) {
					invalidationObject.addEventListener(Event.ENTER_FRAME, enterFrameHandler);
					
				} else {
					invalidationObject.removeEventListener(Event.ENTER_FRAME, enterFrameHandler);
					invalidatedProperties = new Dictionary();
				}
			}
		}
		
		protected function enterFrameHandler(event:Event):void {
			var keys:Array = new Array();
			for (var key:Object in invalidatedProperties) keys.push(key);
			
			dispatchEvent(new InvalidatorEvent(InvalidatorEvent.INVALIDATION, keys));
			setInvalidatePropertiesFlag(false);
		}

	}
}