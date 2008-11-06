package nl.mediamonkey.utils {
	
	import flash.net.SharedObject;
	//import flash.events.EventDispatcher;
	//import flash.events.Event;
	
	public class LSOUserPreferences {
		
		private static var preferences:Array = new Array();
		private static var storedObject:SharedObject;
		//private static var dispatcher:EventDispatcher;
		
		public static var loaded:Boolean = false;
		public static var status:String = "";
		
		// ---- public static methods ----
		
		public static function getPreference(key:String):* {
			return preferences[key] != undefined ? preferences[key] : null;
		}
		
		public static function getAllPreferences():Array {
			return preferences;
		}
		
		/*
		public static function addEventListener(...args):void {
			if (!dispatcher) dispatcher = new EventDispatcher();
			dispatcher.addEventListener.call(null, ...args);
		}
		
		public static function removeEventListener(...args):void {
			if (!dispatcher) dispatcher = new EventDispatcher();
			dispatcher.removeEventListener.call(null, ...args);
		}
		*/
	
		// -- set a local/LSO preference
		public static function setPreference(key:String, value:*, persistent:Boolean = true):void {
			preferences[key] = value;
	
			// -- optionally save to LSO
			if (persistent) {
				
				storedObject.data[key] = value;
				var result:String = storedObject.flush();
				
				switch (result) {
					
					case "pending":
						status = "Flush is pending, waiting on user interaction"; 			
						break;
						
					case true:
						status = "Flush was successful.  Requested Storage Space Approved"; 	
						break;
						
					case false:
						status = "Flush failed.  User denied request for additional space."; 	
						break;
				}
				
				//dispatcher.dispatch(new Event(Event.COMPLETE));
			}
		}
	
		// Load from LSO for now
		public static function load(path:String):void {
			storedObject = SharedObject.getLocal("userPreferences" + path, "/");
			for (var key:String in storedObject.data) {
				preferences[key] = storedObject.data[key];
			}
			loaded = true;
		}
	
		// Clear LSO and reset preferences
		public static function clear():void {
			if (storedObject) {
				storedObject.clear();
				storedObject.flush();
				preferences = new Array();
			}
		}
	}
}