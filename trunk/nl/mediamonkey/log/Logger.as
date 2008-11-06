package nl.mediamonkey.log {
	
	import com.adobe.cairngorm.*;
	
	import flash.events.EventDispatcher;
	
	import mx.logging.*;
	import mx.logging.targets.*;
	
	[Event(name="log", type="mx.logging.LogEvent")]
	
	public class Logger extends EventDispatcher {
		
		private static const _instance:Logger = new Logger(SingletonLock);
		
		public static const LOG:String = "log"; // == LogEvent.LOG
		
		private static var logger:ILogger;
		
		// ---- getters & setters ----
		
		public static function get instance():Logger {
			return _instance;
		}
		
		// ---- constructor & initialization ----
		
		public function Logger(lock:Class) {
			if (lock != SingletonLock) {
				throw new CairngormError(CairngormMessageCodes.SINGLETON_EXCEPTION, "Logger");
			}
			
			logger = Log.getLogger("nl.mediamonkey");
			logger.addEventListener(LogEvent.LOG, logHandler);
		}
		
		// ---- event handlers ----
		
		private function logHandler(event:LogEvent):void {
			dispatchEvent(event);
		}
		
		// ---- public static methods ----
		
		public static function log(level:int, message:String, ... rest:Array):void {
			logger.log(level, message, rest);
		}
		
		public static function debug(... rest:Array):void {
			var message:String = rest.join(" ");
			logger.debug(message);
		}
		
		public static function error(... rest:Array):void {
			var message:String = rest.join(" ");
			logger.error(message);
		}
		
		public static function fatal(... rest:Array):void {
			var message:String = rest.join(" ");
			logger.fatal(message);
		}
		
		public static function info(... rest:Array):void {
			var message:String = rest.join(" ");
			logger.info(message);
		}
		
		public static function warn(... rest:Array):void {
			var message:String = rest.join(" ");
			logger.warn(message);
		}
		
	}
}

internal class SingletonLock {}