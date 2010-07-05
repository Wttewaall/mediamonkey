package nl.mediamonkey.utils.events {
	
	import flash.events.Event;

	public class PopUpEvent extends Event {
		
		public static const CANCEL		:String = "popupCancel";
		public static const CLOSE		:String = "popupClose";
		public static const NO			:String = "popupNo";
		public static const OK			:String = "popupOk";
		public static const SUBMIT		:String = "popupSubmit";
		public static const YES			:String = "popupYes";
		
		public var data:Object;
		public var closeOnEvent:Boolean;
		
		public function PopUpEvent(type:String, data:Object=null, closeOnEvent:Boolean=true, bubbles:Boolean=true, cancelable:Boolean=true) {
			super(type, bubbles, cancelable);
			this.data = data;
			this.closeOnEvent = closeOnEvent;
		}
		
	}
}