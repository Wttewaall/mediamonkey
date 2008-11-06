package nl.mediamonkey.events {
	
	import flash.events.Event;
	
	public class InvalidatorEvent extends Event {
		
		public static const INVALIDATION	:String = "invalidation";
		
		public var invalidatedProperties	:Array;
		
		public function InvalidatorEvent(type:String, invalidatedProperties:Array, bubbles:Boolean=false, cancelable:Boolean=false) {
			super(type, bubbles, cancelable);
			this.invalidatedProperties = invalidatedProperties;
		}
		
	}
}