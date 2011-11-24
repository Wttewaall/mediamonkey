package nl.mediamonkey.utils {
	
	import flash.display.InteractiveObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.ui.Mouse;
	import flash.utils.Dictionary;
	
	import mx.core.Application;
	import mx.core.FlexGlobals;
	import mx.managers.CursorManager;
	import mx.managers.ISystemManager;
	
	import nl.mediamonkey.utils.data.Cursor;
	
	public class CursorUtil {
		
		private static var dictionary:Dictionary = new Dictionary(true);
		
		// ---- getters & setters ----
		
		private static var _currentCursorID:int = -1;
		private static var _currentCursor:Class;
		
		public static function get currentCursorID():int {
			return _currentCursorID;
		}
		
		public static function get currentCursor():Class {
			return _currentCursor;
		}
		
		// ---- public static methods ----
		
		public static function register(object:InteractiveObject, cursor:Cursor, overEvents:Array=null, outEvents:Array=null):void {
			if (!dictionary[object]) {
				var eventName:String;
				
				object.addEventListener(MouseEvent.MOUSE_MOVE, cursorMoveHandler);
				
				if (!overEvents) {
					object.addEventListener(MouseEvent.ROLL_OVER, cursorOverHandler);
					
				} else {
					for each (eventName in overEvents)
						object.addEventListener(eventName, cursorOverHandler);
				}
				
				if (!outEvents) {
					object.addEventListener(MouseEvent.ROLL_OUT, cursorOutHandler);
					
				} else {
					for each (eventName in outEvents)
						object.addEventListener(eventName, cursorOutHandler);
				}
			}
			
			dictionary[object] = new CursorValue(cursor, overEvents, outEvents);
		}
		
		public static function unregister(object:InteractiveObject):void {
			if (dictionary[object]) {
				var value:CursorValue = dictionary[object] as CursorValue;
				var eventName:String;
				
				if (value) {
					
					for each (eventName in value.overEvents)
						object.removeEventListener(eventName, cursorOverHandler);
						
					for each (eventName in value.outEvents)
						object.removeEventListener(eventName, cursorOutHandler);
					
					delete dictionary[object];
				}
			}
		}
		
		public static function setCursor(cursorIcon:Class, priority:int=2, offsetX:Number=0, offsetY:Number=0):int {
			if (currentCursorID != CursorManager.currentCursorID) {
				CursorManager.removeCursor(CursorManager.currentCursorID);
				
				if (cursorIcon != null) {
					_currentCursor = cursorIcon;
					_currentCursorID = CursorManager.setCursor(cursorIcon, priority, offsetX, offsetY);
				}
			}
			return currentCursorID;
		}
		
		public static function setCursorByVO(vo:Cursor, forceUpdate:Boolean=false):int {
			if (vo == null) return CursorManager.currentCursorID;
			
			if (currentCursorID != CursorManager.currentCursorID || forceUpdate) {
				CursorManager.removeCursor(CursorManager.currentCursorID);
				
				if (vo.cursorIcon != null) {
					_currentCursor = vo.cursorIcon;
					_currentCursorID = CursorManager.setCursor(vo.cursorIcon, vo.priority, vo.offsetX, vo.offsetY);
				}
				
				getCursorHolder().blendMode = vo.blendMode;
				if (!vo.hideMouse) Mouse.show();
			}
			return currentCursorID;
		}
		
		public static function removeCurrentCursor():void {
			CursorManager.removeCursor(CursorManager.currentCursorID);
		}
		
		public static function removeAllCursors():void {
			CursorManager.removeAllCursors();
		}
		
		public static function hideCursor():void {
			CursorManager.hideCursor();
		}
		
		public static function removeBusyCursor():void {
			CursorManager.removeBusyCursor();
		}
		
		public static function setBusyCursor():void {
			CursorManager.setBusyCursor();
		}
		
		public static function showCursor():void {
			CursorManager.showCursor();
		}
		
		public static function getCursorHolder():Sprite {
			var systemManager:ISystemManager = FlexGlobals.topLevelApplication.systemManager;
			//var systemManager:ISystemManager = Application.application.systemManager;
			return systemManager.cursorChildren.getChildAt(systemManager.cursorChildren.numChildren-1) as Sprite;
		}
		
		// ---- event handlers ----
		
		protected static function cursorOverHandler(event:MouseEvent):void {
			var value:CursorValue = dictionary[event.currentTarget] as CursorValue;
			if (value) setCursorByVO(value.cursor);
		}
		
		protected static function cursorOutHandler(event:MouseEvent):void {
			removeCurrentCursor();
		}
		
		protected static function cursorMoveHandler(event:MouseEvent):void {
			var value:CursorValue = dictionary[event.currentTarget] as CursorValue;
			if (value.cursor.hideMouse == false) Mouse.show();
		}
		
	}
}

// ---- CursorValue ----

import flash.events.MouseEvent;

import nl.mediamonkey.utils.CursorUtil;
import nl.mediamonkey.utils.data.Cursor;

class CursorValue {
	
	public var cursor:Cursor;
	public var overEvents:Array;
	public var outEvents:Array;
	
	public function CursorValue(cursor:Cursor, overEvents:Array=null, outEvents:Array=null) {
		this.cursor = cursor;
		this.overEvents = (overEvents) ? overEvents : [MouseEvent.ROLL_OVER];
		this.outEvents = (outEvents) ? outEvents : [MouseEvent.ROLL_OUT];
	}
	
}