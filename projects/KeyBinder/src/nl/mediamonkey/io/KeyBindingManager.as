package nl.mediamonkey.io {
	
	import flash.display.InteractiveObject;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.KeyboardEvent;
	import flash.utils.Dictionary;
	import flash.utils.getDefinitionByName;
	
	import nl.mediamonkey.enum.Key;
	
	[Event(name="keyDown", type="flash.events.KeyboardEvent")]
	[Event(name="keyUp", type="flash.events.KeyboardEvent")]
	
	[Event(name="ctrlChange", type="flash.events.KeyboardEvent")]
	[Event(name="altChange", type="flash.events.KeyboardEvent")]
	[Event(name="shiftChange", type="flash.events.KeyboardEvent")]
	
	public class KeyBindingManager extends EventDispatcher {
		
		public static const CTRL_CHANGE		:String = "ctrlChange";
		public static const ALT_CHANGE		:String = "altChange";
		public static const SHIFT_CHANGE	:String = "shiftChange";
		
		private var keysMap			:Dictionary;
		private var keyDown			:Boolean;
		private var keyChanged		:Boolean;
		private var ctrlDown		:Boolean;
		private var altDown			:Boolean;
		private var shiftDown		:Boolean;
		
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
		public function bindKeyWithEvent(keyCode:Object, scope:Object, event:Event, allowMultiBinding:Boolean=false, triggerOnDown:Boolean=true):Boolean {
			return bindKeyWithAction(keyCode, scope, event, null, null, allowMultiBinding, triggerOnDown);
		}
		
		public function bindKeyWithFunction(keyCode:Object, scope:Object, func:Function, arguments:Array=null, allowMultiBinding:Boolean=false, triggerOnDown:Boolean=true):Boolean {
			return bindKeyWithAction(keyCode, scope, null, func, arguments, allowMultiBinding, triggerOnDown);
		}
		
		private var poll:KeyPoll;
		
		public function bindKeyWithHandler(keyCode:Object, handler:Function):void {
			if (!poll) poll = new KeyPoll(target.stage);
			poll.addEventListener(KeyboardEvent.KEY_DOWN, handler);
			poll.addEventListener(KeyboardEvent.KEY_UP, handler);
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
		
		private function bindKeyWithAction(keyCode:Object, scope:Object, event:Event=null, func:Function=null, arguments:Array=null, allowMultiBinding:Boolean=false, triggerOnDown:Boolean=true):Boolean {
			var group:KeyGroup;
			var code:uint;
			
			if (keyCode is uint) code = keyCode as uint;
			else if (keyCode is Key) code = (keyCode as Key).code;
			else if (keyCode is String) code = parseInt(keyCode as String);
			else throw new ArgumentError("invalid keyCode type");
			
			if (keysMap[code] != null) {
				
				if (allowMultiBinding) {
					
					if (keysMap[code] is KeyItem) {
						group = new KeyGroup(code, [keysMap[code]]);
						keysMap[code] = group;
						group.items.push(new KeyItem(code, scope, event, func, arguments, triggerOnDown));
						return true;
						
					} else if (keysMap[code] is KeyGroup) {
						group = keysMap[code] as KeyGroup;
						group.items.push(new KeyItem(code, scope, event, func, arguments, triggerOnDown));
						return true;
						
					} else {
						return false;
					}
					
				} else {
					// contains key + no multibinding allowed
					return false;
				}
				
			} else {
				keysMap[code] = new KeyItem(code, scope, event, func, arguments, triggerOnDown);
				return true;
			}
		}
		
		private function keyHandler(event:KeyboardEvent):void {
			if (!keyChanged) return; // ignore multiple keystrokes when keeping the key pressed down
			
			var downEvent:Boolean = (event.type == KeyboardEvent.KEY_DOWN);
			var item:KeyItem;
			
			if (keysMap[event.keyCode] is KeyItem) {
				item = keysMap[event.keyCode] as KeyItem;
				if ((!downEvent && !item.triggerOnDown) || (downEvent && item.triggerOnDown)) triggerItem(item, event);
				
			} else if (keysMap[event.keyCode] is KeyGroup) {
				var group:KeyGroup = keysMap[event.keyCode] as KeyGroup;
				
				for (var i:uint=0; i<group.items.length; i++) {
					item = group.items[i] as KeyItem;
					if ((!downEvent && !item.triggerOnDown) || (downEvent && item.triggerOnDown)) triggerItem(item, event);
				}
			}
			
			dispatchEvent(event);
		}
		
		private function dispatchKeyboardEvent(type:String, event:KeyboardEvent):void {
			dispatchEvent(new KeyboardEvent(type, true, false, event.charCode, event.keyCode, event.keyLocation, event.ctrlKey, event.altKey, event.shiftKey));
		}
		
		private function triggerItem(item:KeyItem, event:KeyboardEvent):void {
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
				/*if (item.scope === this) {
					item.func.apply(null, [event]); // call handler
				}*/
				item.func.apply(item.scope, item.arguments);
			}
			
			var type:String = Key.getKeyByCode(item.keyCode).description;
			dispatchKeyboardEvent(type, event);
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