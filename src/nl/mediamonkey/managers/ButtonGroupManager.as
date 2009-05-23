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
		protected static var groups:Array = new Array();
		
		public static function registerButton(button:Button, group:ButtonGroup):void {
			if (!contains(button)) {
				button.addEventListener(Event.REMOVED_FROM_STAGE, removeHandler);
			}
			buttons[button] = group;
			group.addButton(button);
			
			// add group if not yet added
			if (groups.indexOf(group) == -1) groups.push(group);
		}
		
		public static function unregisterButton(button:Button, removeEmptyGroup:Boolean=false):void {
			if (contains(button)) {
				button.removeEventListener(Event.REMOVED_FROM_STAGE, removeHandler);
				
				var group:ButtonGroup = getGroup(button);
				group.removeButton(button);
				buttons[button] = null;
				
				if (removeEmptyGroup && group.length == 0) {
					var index:int = groups.indexOf(group);
					if (index > -1) groups.splice(index, 1);
				}
			}
		}
		
		public static function addGroup(group:ButtonGroup):void {
			for (var i:uint=0; i<group.length; i++) {
				registerButton(group.getButtonAt(i), group);
			}
		}
		
		public static function removeGroup(group:ButtonGroup):void {
			for (var i:uint=0; i<group.length; i++) {
				unregisterButton(group.getButtonAt(i), true);
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
			unregisterButton(event.target as Button);
		}
		
		// ---- protected methods ----
		
		protected static function contains(button:Button):Boolean {
			return (buttons[button] != null);
		}
		
	}
}