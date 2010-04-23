package nl.mediamonkey.io {
	
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.KeyboardEvent;
	
	import nl.mediamonkey.io.KeyPoll;
	
	public class KeyBinder extends EventDispatcher {
		
		private static const CTRL		:uint = 17;
		private static const ALT		:uint = 18; // or 15
		private static const SHIFT		:uint = 16;
		
		protected var keyPoll			:KeyPoll;
		protected var downKeys			:Array;
		
		// allowMultiBinding
		
		private var library:Array = [];
		
		// ---- constructor ----
		
		public function KeyBinder(stage:Stage) {
			stage.addEventListener(Event.DEACTIVATE, deactivateListener, false, 0, true);
			
			keyPoll = new KeyPoll(stage);
			keyPoll.addEventListener(KeyboardEvent.KEY_DOWN, keyHandler);
			keyPoll.addEventListener(KeyboardEvent.KEY_UP, keyHandler);
			
			downKeys = new Array();
		}
		
		// ---- event handlers ----
		
		protected function deactivateListener(event:Event):void {
			downKeys = [];
		}
		
		protected function keyHandler(event:KeyboardEvent):void {
			if (event.type == KeyboardEvent.KEY_DOWN) {
				downKeys.push(event.keyCode);
				
			} else if (event.type == KeyboardEvent.KEY_UP) {
				var index:int = downKeys.indexOf(event.keyCode);
				if (index > -1) downKeys.splice(index, 1);
				
			} else throw new Error("no such event type expected:", event.type);
			
			//trace("downKeys:", downKeys);
			
			/** search **/
			//..
			
			/*var bitCode:uint = getBitCodeFromEvent(event);
			if (library[bitCode]) {
				var type:String = ""//(keyPoll.hasBitMask(bitCode)) ? KeyboardEvent.KEY_DOWN : KeyboardEvent.KEY_UP;
				//var evt:Event = new Event(type, library[bitCode]);
				//dispatchEvent(evt);
			}*/
		}
		
		public function bind(key:Object, handler:Function):Boolean {
			var combo:KeyCombo = new KeyCombo(key, handler);
			if (library[combo.key]) return false;
			else library[combo.key] = combo;
			return true;
		}
		
		public function unbind(key:Object):void {
			//var bitCode:uint = getBitCodeFromObject(key);
			//delete library[bitCode];
		}
		
		public function getBindings():Array {
			return library;
		}
		
	}
}

// ---- internal KeyCombo class ----

import nl.mediamonkey.enum.Key;
import flash.utils.getQualifiedClassName;

internal class KeyCombo {
	
	// ---- getters & setters ----
	
	private var _key:Key;
	private var _handler:Function;
	private var _alt:Boolean;
	private var _ctrl:Boolean;
	private var _shift:Boolean;
	
	public function get key():Key {
		return _key;
	}
	
	public function get handler():Function {
		return _handler;
	}
	
	public function get alt():Boolean {
		return _alt;
	}
	
	public function get ctrl():Boolean {
		return _ctrl;
	}
	
	public function get shift():Boolean {
		return _shift;
	}
	
	// ---- constructor ----
	
	public function KeyCombo(key:Object, handler:Function) {
		_handler = handler;
		
		var keys:Array;
		if (key is Array) keys = convertToKeyArray(key as Array);
		else keys = [convertToKey(key)];
		
		build(keys);
	}
	
	protected function convertToKeyArray(arr:Array):Array {
		var result:Array = [];
		
		for (var i:int=0; i<arr.length; i++) {
			var key:Key = convertToKey(arr[i]);
			if (key) result.push(key);
		}
		
		return result;
	}
	
	protected function convertToKey(obj:Object):Key {
		var args:Array = getQualifiedClassName(obj).split("::");
		var className:String = args[args.length-1];
		
		switch (className) {
			case "Key": return obj as Key;
			case "int": return Key.getKeyByCode(obj as int);
			default: return null;
		}
	}
	
	protected function build(arr:Array):void {
		if (arr == null) throw new ArgumentError("argument cannot be null");
		var index:int;
		
		// search for ALT key
		index = arr.indexOf(Key.ALT);
		if (index > -1) {
			_alt = true;
			arr.splice(index, 1);
		}
			
		// search for CTRL key
		index = arr.indexOf(Key.CONTROL);
		if (index > -1) {
			_ctrl = true;
			arr.splice(index, 1);
		}
		
		// search for SHIFT key
		index = arr.indexOf(Key.SHIFT);
		if (index > -1) {
			_shift = true;
			arr.splice(index, 1);
		}
		
		/** TODO: add functionality to also bind only to ALT, CTRL or SHIFT*/
		if (arr.length == 0) throw new Error("You cannot bind to only ALT, CTRL or SHIFT");
		else if (arr.length == 1) _key = arr[0] as Key;
		/** TODO: add functionality to bind to multiple keys */
		else throw new Error("cannot bind to more than one key at a time");
	}
	
	public function toString():String {
		return "[KeyCombo{key:"+key+" alt:"+alt+" ctrl:"+ctrl+" shift:"+shift+"}]";
	}
	
}