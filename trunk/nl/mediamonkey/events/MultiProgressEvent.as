package nl.mediamonkey.events {
	
	import flash.events.Event;
	import flash.net.URLLoader;
	import flash.net.URLRequest;

	public class MultiProgressEvent extends Event {
		
		public static const ITEM_OPEN		:String = "item_open";
		public static const ITEM_COMPLETE	:String = "item_complete";
		public static const ITEM_PROGRESS	:String = "item_progress";
		
		public var request:URLRequest;
		public var loader:URLLoader;
		
		public function MultiProgressEvent(type:String, request:URLRequest, loader:URLLoader, bubbles:Boolean=true, cancelable:Boolean=true) {
			super(type, bubbles, cancelable);
			this.request = request;
			this.loader = loader;
		}
		
	}
}