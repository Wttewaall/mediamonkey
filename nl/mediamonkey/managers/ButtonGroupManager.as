/**
 * To do:
 * . fix buttons/groups dictionaries
 * . on removeButton in group, callback and unregister accordingly
 * 
 */

package nl.mediamonkey.managers {
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.utils.Dictionary;
	
	import mx.controls.Button;
	
	public class ButtonGroupManager extends EventDispatcher {
		
		protected static var buttons:Dictionary = new Dictionary(true);
		protected static var groups:Dictionary = new Dictionary(true);
		
		public static function register(button:Button, group:ButtonGroup):void {
			if (!contains(button)) {
				button.addEventListener(Event.REMOVED_FROM_STAGE, removeHandler);
			}
			buttons[button] = group;
			group.addButton(button);
		}
		
		public static function unregister(button:Button):void {
			if (contains(button)) {
				button.removeEventListener(Event.REMOVED_FROM_STAGE, removeHandler);
				
				var group:ButtonGroup = getGroup(button);
				group.removeButton(button);
				buttons[button] = null;
			}
		}
		
		public static function getGroup(button:Button):ButtonGroup {
			if (contains(button)) return buttons[button] as ButtonGroup;
			else return null;
		}
		
		public static function getButtons(group:ButtonGroup):Array {
			var result:Array = new Array();
			for (var i:String in buttons) {
				if (buttons[i] == group) result.push(i);
			}
			return (result.length > 0) ? result : null;
		}
		
		// ---- event handlers ----
		
		protected static function removeHandler(event:Event):void {
			unregister(event.target as Button);
		}
		
		// ---- protected methods ----
		
		protected static function contains(button:Button):Boolean {
			return (buttons[button] != null);
		}
		
	}
}