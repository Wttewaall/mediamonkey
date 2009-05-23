package nl.mediamonkey.utils {
	
	import flash.display.DisplayObject;
	import flash.events.KeyboardEvent;
	import flash.text.TextField;
	
	/**
	 * Static class that shows a message or animation when a certain key-combination is pressed.
	 */
	
	public class EasterEgg {
		
		private static const KEYWORD:String = "mediamonkey";
		
		private static var target:DisplayObject;
		private static var cursor:uint = 0;
		
		public static function initialize(target:DisplayObject):void {
			if (target == null) throw new ArgumentError("Target must be of type DisplayObject and cannot be null.");
			EasterEgg.target = target;
			target.addEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler);
		}
		
		// ---- event handlers ----
		
		private static function keyDownHandler(event:KeyboardEvent):void {
			// ignore when typing in a TextField
			if (target.stage.focus is TextField) return;
			
			// validate char at cursor
			if (String.fromCharCode(event.charCode) == KEYWORD.charAt(cursor)) {
				if (cursor == KEYWORD.length - 1) {
					showEasterEgg();
					cursor = 0;
				} else {
					cursor++;
				}
			} else {
				cursor = 0;
			}
		}
		
		// ---- methods ----
		
		private static function showEasterEgg():void {
			trace("EasterEgg");
		}

	}
}