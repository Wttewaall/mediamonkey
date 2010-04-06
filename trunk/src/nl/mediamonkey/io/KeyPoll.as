package nl.mediamonkey.io {
	
	/**
	 * From http://code.google.com/p/bigroom/wiki/KeyPoll
	 */
	
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.KeyboardEvent;
	import flash.utils.ByteArray;
	
	[Event(name="keyDown",		type="flash.events.KeyboardEvent")]
	[Event(name="keyUp",		type="flash.events.KeyboardEvent")]
	
	public class KeyPoll extends EventDispatcher {
		
		protected var states		:ByteArray;
		protected var dispObj		:DisplayObject;
		
		public function KeyPoll(stage:DisplayObject) {
			
			// create state of 8 * 32 bits = 256 states
			states = new ByteArray();
			states.writeUnsignedInt(0);
			states.writeUnsignedInt(0);
			states.writeUnsignedInt(0);
			states.writeUnsignedInt(0);
			states.writeUnsignedInt(0);
			states.writeUnsignedInt(0);
			states.writeUnsignedInt(0);
			states.writeUnsignedInt(0);
			
			dispObj = stage;
			dispObj.addEventListener(KeyboardEvent.KEY_DOWN, keyDownListener, false, 0, true);
			dispObj.addEventListener(KeyboardEvent.KEY_UP, keyUpListener, false, 0, true);
			dispObj.addEventListener(Event.ACTIVATE, activateListener, false, 0, true);
			dispObj.addEventListener(Event.DEACTIVATE, deactivateListener, false, 0, true);
		}
		
		// ---- public methods ----
		
		public function isDown(keyCode:uint):Boolean {
			return (states[keyCode >>> 3] & (1 << (keyCode & 7))) != 0;
		}
		
		public function isUp(keyCode:uint):Boolean {
			return (states[keyCode >>> 3] & (1 << (keyCode & 7))) == 0;
		}
		
		public function getDownKeys():Array {
			var result:Array = [];
			
			var i:uint=0;
			var j:uint=0;
			var currentUint:uint;
			var keyCode:uint;
			
			states.position = 0;
			
			while (states.bytesAvailable) {
				currentUint = states.readUnsignedInt();
				
				if (currentUint > 0) { // else skip empty uint
					
					for (j=0; j<32; j++) {
						keyCode = i * 32 + j;
						if (isDown(keyCode)) result.push(keyCode);
					}
				}
				
				i++;
			}
			
			states.position = 0;
			
			//if (sortMethod > 0) result.sort(sortMethod);
			
			return result;
		}
		
		override public function toString():String {
			var result:String = "";
			var currentUint:uint;
			var currentUintString:String;
			
			states.position = 0;
			
			while (states.bytesAvailable) {
				currentUint = states.readUnsignedInt();
				currentUintString = currentUint.toString(2);
				
				while (currentUintString.length < 32) currentUintString= "0" + currentUintString;
				result += currentUintString + "\n";
			}
			
			states.position = 0;
			
			return result;
		}
		
		// ---- event handlers ----
		
		protected function keyDownListener(event:KeyboardEvent):void {
			var change:Boolean = isUp(event.keyCode);
			states[event.keyCode >>> 3] |= 1 << (event.keyCode & 7);
			
			if (change)
				dispatchEvent(new KeyboardEvent(KeyboardEvent.KEY_DOWN, false, false, event.charCode, event.keyCode, event.keyLocation, event.ctrlKey, event.altKey, event.shiftKey));
		}
		
		protected function keyUpListener(event:KeyboardEvent):void {
			var change:Boolean = isDown(event.keyCode);
			states[event.keyCode >>> 3] &= ~(1 << (event.keyCode & 7));
			
			if (change)
				dispatchEvent(new KeyboardEvent(KeyboardEvent.KEY_UP, false, false, event.charCode, event.keyCode, event.keyLocation, event.ctrlKey, event.altKey, event.shiftKey));
		}
		
		// ---- protected methods ----
		
		protected function activateListener(event:Event):void {
			resetStates();
		}
		
		protected function deactivateListener(event:Event):void {
			resetStates();
		}
		
		protected function resetStates():void {
			for (var i:uint=0; i<8; i++) {
				states[i] = 0;
			}
		}
	}
}