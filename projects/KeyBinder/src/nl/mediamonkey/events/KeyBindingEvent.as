package nl.mediamonkey.events {
	
	import flash.events.Event;

	public class KeyBindingEvent extends Event {
		
		public static const KEY_DOWN	:String = "keyDown";
		public static const KEY_UP		:String = "keyUp";
		
		public var key:Object;
		
		public function KeyBindingEvent(type:String, key:Object=null, bubbles:Boolean=true, cancelable:Boolean=true) {
			super(type, bubbles, cancelable);
			this.key = key;
		}
		
		override public function clone():Event {
			return new KeyBindingEvent(type, key, bubbles, cancelable);
		}
		
	}
}