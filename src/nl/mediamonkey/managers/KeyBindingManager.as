package nl.mediamonkey.managers {
	
	import flash.display.InteractiveObject;
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	import flash.events.KeyboardEvent;
	import flash.utils.Dictionary;
	
	public class KeyBindingManager {
		
		private var keysMap:Dictionary;
		private var keyDown:Boolean;
		private var keyChanged:Boolean;
		
		// ---- getters & setters ----
		
		private var _target:InteractiveObject;
		
		public function get target():InteractiveObject {
			return _target;
		}
		
		public function set target(value:InteractiveObject):void {
			if (_target !== value) {
				if (_target) removeListeners(_target);
				_target = value;
				if (_target) addListeners(_target);
			}
		}
		
		// ---- constructor ----
		
		public function KeyBindingManager(target:InteractiveObject) {
			keysMap = new Dictionary();
			this.target = target;
		}
		
		// ---- public methods ----
		
		/**
		 * Returns wether the key could be bound to the event (will not succeed if key is occupied) 
		 **/
		public function bindKeyWithEvent(keyCode:uint, scope:Object, event:Event, allowMultiBinding:Boolean=false, triggerOnDown:Boolean=true):Boolean {
			return bindKeyWithAction(keyCode, scope, event, null, null, allowMultiBinding, triggerOnDown);
		}
		
		public function bindKeyWithFunction(keyCode:uint, scope:Object, func:Function, arguments:Array=null, allowMultiBinding:Boolean=false, triggerOnDown:Boolean=true):Boolean {
			return bindKeyWithAction(keyCode, scope, null, func, arguments, allowMultiBinding, triggerOnDown);
		}
		
		public function getKeyByEvent(event:Event):Array {
			var result:Array = new Array();
			var item:KeyItem;
			
			for (var keyCode:* in keysMap) {
				
				if (keysMap[keyCode] is KeyItem) {
					if ((keysMap[keyCode] as KeyItem).event === event) result.push(keyCode);
					
				} else if (keysMap[keyCode] is KeyGroup) {
					var group:KeyGroup = keysMap[keyCode] as KeyGroup;
					
					for (var i:uint=0; i<group.items.length; i++) {
						if ((group.items[i] as KeyItem).event === event) result.push(keyCode);
					}
				}
			}
			return result;
		}
		
		public function getKeyBindings():Array {
			var result:Array = new Array();
			for (var keyCode:* in keysMap) result.push(keysMap[keyCode] as KeyItem);
			return result;
		}
		
		public function getCodeBindings():Array {
			var result:Array = new Array();
			var item:KeyItem;
			for (var keyCode:* in keysMap) {
				item = keysMap[keyCode] as KeyItem;
				result.push(item.keyCode);
			}
			return result;
		}
		
		public function getCharBindings():Array {
			var result:Array = new Array();
			var item:KeyItem;
			for (var keyCode:* in keysMap) {
				item = keysMap[keyCode] as KeyItem;
				result.push(String.fromCharCode(item.keyCode));
			}
			return result;
		}
		
		// ---- private methods ----
		
		private function addListeners(target:IEventDispatcher):void {
			target.addEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler);
			target.addEventListener(KeyboardEvent.KEY_UP, keyUpHandler);
		}
		
		private function removeListeners(target:IEventDispatcher):void {
			target.removeEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler);
			target.removeEventListener(KeyboardEvent.KEY_UP, keyUpHandler);
		}
		
		private function bindKeyWithAction(keyCode:uint, scope:Object, event:Event=null, func:Function=null, arguments:Array=null, allowMultiBinding:Boolean=false, triggerOnDown:Boolean=true):Boolean {
			var group:KeyGroup;
			
			if (keysMap[keyCode] != null) {
				
				if (allowMultiBinding) {
					
					if (keysMap[keyCode] is KeyItem) {
						group = new KeyGroup(keyCode, [keysMap[keyCode]]);
						keysMap[keyCode] = group;
						group.items.push(new KeyItem(keyCode, scope, event, func, arguments, triggerOnDown));
						return true;
						
					} else if (keysMap[keyCode] is KeyGroup) {
						group = keysMap[keyCode] as KeyGroup;
						group.items.push(new KeyItem(keyCode, scope, event, func, arguments, triggerOnDown));
						return true;
						
					} else {
						return false;
					}
					
				} else {
					// contains key + no multibinding allowed
					return false;
				}
				
			} else {
				keysMap[keyCode] = new KeyItem(keyCode, scope, event, func, arguments, triggerOnDown);
				return true;
			}
		}
		
		private function keyHandler(event:KeyboardEvent):void {
			if (!keyChanged) return; // ignore multiple keystrokes when keeping the key pressed down
			
			var downEvent:Boolean = (event.type == KeyboardEvent.KEY_DOWN);
			var item:KeyItem;
			
			if (keysMap[event.keyCode] is KeyItem) {
				item = keysMap[event.keyCode] as KeyItem;
				if ((!downEvent && !item.triggerOnDown) || (downEvent && item.triggerOnDown)) triggerItem(item);
				
			} else if (keysMap[event.keyCode] is KeyGroup) {
				var group:KeyGroup = keysMap[event.keyCode] as KeyGroup;
				
				for (var i:uint=0; i<group.items.length; i++) {
					item = group.items[i] as KeyItem;
					if ((!downEvent && !item.triggerOnDown) || (downEvent && item.triggerOnDown)) triggerItem(item);
				}
			}
		}
		
		private function triggerItem(item:KeyItem):void {
			if (item.event) {
				
				/**
				 * Important: add a clone method that returns a true clone.
				 * Don't use the default CairngormEvent or UMEvent clone method
				 */
				
				// Cairngorm event, self-dispatched
				if (item.event.hasOwnProperty("dispatch")) {
					(item.event.clone()["dispatch"] as Function).call(null);
				
				// Flash event, dispatched by scope
				} else if (item.scope is IEventDispatcher) {
					(item.scope as IEventDispatcher).dispatchEvent(item.event.clone());
				}
			}
			
			if (item.func != null) {
				item.func.apply(item.scope, item.arguments);
			}
		}
		
		// ---- event handlers ----
		
		private function keyDownHandler(event:KeyboardEvent):void {
			if (keyDown == false) {
				keyDown = true;
				keyChanged = true;
			} else {
				keyChanged = false;
			}
			
			keyHandler(event);
		}
		
		private function keyUpHandler(event:KeyboardEvent):void {
			if (keyDown == true) {
				keyDown = false;
				keyChanged = true;
			} else {
				keyChanged = false;
			}
			
			keyHandler(event);
		}
		
	}
}

import flash.events.Event;

class KeyItem {
	
	public var keyCode:uint;
	public var scope:Object;
	public var event:Event;
	public var func:Function;
	public var arguments:Array;
	public var triggerOnDown:Boolean;
	
	public function KeyItem(keyCode:uint, scope:Object, event:Event=null, func:Function=null, arguments:Array=null, triggerOnDown:Boolean=false) {
		this.keyCode = keyCode;
		this.scope = scope;
		this.event = event;
		this.func = func;
		this.arguments = arguments;
		this.triggerOnDown = triggerOnDown;
	}
	
}

class KeyGroup {
	
	public var keyCode:uint;
	public var items:Array;
	
	public function KeyGroup(keyCode:uint, items:Array) {
		this.keyCode = keyCode;
		this.items = items;
	}
	
}