package nl.mediamonkey.communication {
	
	import flash.events.*;
	import mx.controls.Alert;
	import flash.net.LocalConnection;
	import flash.events.SecurityErrorEvent;
	import nl.mediamonkey.communication.events.LocalConnectionEvent;
	
	public class FlashConnection extends EventDispatcher {
		
		private static var sending_lc:DynamicLocalConnection;
		private static var receiving_lc:DynamicLocalConnection;
		
		public function FlashConnection() {
			if (!sending_lc) {
				sending_lc = new DynamicLocalConnection();
				sending_lc.addEventListener(SecurityErrorEvent.SECURITY_ERROR, dispatchEvent);
			}
			if (!receiving_lc) {
				receiving_lc = new DynamicLocalConnection();
				receiving_lc.addEventListener(SecurityErrorEvent.SECURITY_ERROR, dispatchEvent);
			}
			
			receiving_lc.methodHandler = this.methodHandler;
			
			try {
				receiving_lc.connect("connectionFlashFlex");
			} catch(e:Error) {
				var evt:LocalConnectionEvent = new LocalConnectionEvent(LocalConnectionEvent.ERROR, e.message);
				dispatchEvent(evt);
			}
		}
		
		private function methodHandler(flashEvent:Object):void {
			// create a new event with type="receive". Casting the flashEvent object doesn't work
			var evt:LocalConnectionEvent = new LocalConnectionEvent(LocalConnectionEvent.RECEIVE, flashEvent.value);
			dispatchEvent(evt);
		}
		
		public function sendConnectionEvent(evt:LocalConnectionEvent):void {
			sending_lc.send("connectionFlexFlash", "methodHandler", evt);
			dispatchEvent(evt);
		}
		
	}
	
}

import flash.net.LocalConnection;
import flash.events.SecurityErrorEvent;

dynamic internal class DynamicLocalConnection extends LocalConnection {
	
	public function DynamicLocalConnection() {
		//addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
	}
	
	/*private function securityErrorHandler(evt:SecurityErrorEvent):void {
		trace("securityErrorHandler: "+evt);
	}*/
}