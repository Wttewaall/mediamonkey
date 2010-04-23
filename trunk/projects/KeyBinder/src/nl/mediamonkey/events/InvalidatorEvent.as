package nl.mediamonkey.events {
	
	import flash.events.Event;
	
	import nl.mediamonkey.enum.InvalidationType;
	
	public class InvalidatorEvent extends Event {
		
		public static const INVALIDATION	:String = "invalidation";
		
		public var invalidatedProperties	:Array;
		
		public function InvalidatorEvent(type:String, invalidatedProperties:Array, bubbles:Boolean=false, cancelable:Boolean=false) {
			super(type, bubbles, cancelable);
			this.invalidatedProperties = invalidatedProperties;
		}
		
		public function contains(prop:String):Boolean {
			var hasProp:Boolean = (invalidatedProperties.indexOf(prop) > -1);
			var hasAll:Boolean = (invalidatedProperties.indexOf(InvalidationType.ALL) > -1);
			return (hasProp || hasAll);
		}
		
	}
}