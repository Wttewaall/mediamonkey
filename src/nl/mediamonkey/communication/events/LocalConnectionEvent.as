package nl.mediamonkey.communication.events {
	
	import flash.events.Event;

	public dynamic class LocalConnectionEvent extends Event	{
		
		public static const RECEIVE:String = "receive";
		public static const SEND:String = "send";
		public static const ERROR:String = "error";
		
		public var value:Object;
		
		public function LocalConnectionEvent(type:String, value:Object) {
			super(type, false, false);
			this.value = value;
		}
		
		override public function clone():Event {
			return new LocalConnectionEvent(type, value);
		}
	}
}