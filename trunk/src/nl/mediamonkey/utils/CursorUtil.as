package nl.mediamonkey.utils {
	
	import flash.display.InteractiveObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.utils.Dictionary;
	
	import mx.core.ApplicationGlobals;
	import mx.managers.CursorManager;
	import mx.managers.ISystemManager;
	
	public class CursorUtil {
		
		public static const ROLL_OVER:String = "rollOver";
		public static const ROLL_OUT:String = "rollOut";
		
		private static var currentCursorID:int = -1;
		private static var dictionary:Dictionary = new Dictionary(true);
		
		// ---- public static methods ----
		
		public static function register(object:InteractiveObject, cursor:CursorVO, overEvents:Array=null, outEvents:Array=null):void {
			if (!dictionary[object]) {
				var eventName:String;
				
				if (!overEvents) {
					object.addEventListener(ROLL_OVER, cursorOverHandler);
					
				} else {
					for each (eventName in overEvents)
						object.addEventListener(eventName, cursorOverHandler);
				}
				
				if (!outEvents) {
					object.addEventListener(ROLL_OUT, cursorOutHandler);
					
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
					currentCursorID = CursorManager.setCursor(cursorIcon, priority, offsetX, offsetY);
				}
			}
			return currentCursorID;
		}
		
		public static function setCursorByVO(vo:CursorVO, forceUpdate:Boolean=false):int {
			if (vo == null) return CursorManager.currentCursorID;
			
			if (currentCursorID != CursorManager.currentCursorID || forceUpdate) {
				CursorManager.removeCursor(CursorManager.currentCursorID);
				
				if (vo.cursorIcon != null) {
					currentCursorID = CursorManager.setCursor(vo.cursorIcon, vo.priority, vo.offsetX, vo.offsetY);
				}
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
			var systemManager:ISystemManager = ApplicationGlobals.application.systemManager;
			return systemManager.cursorChildren.getChildAt(systemManager.cursorChildren.numChildren-1) as Sprite;
		}
		
		// ---- event handlers ----
		
		protected static function cursorOverHandler(event:Event):void {
			var value:CursorValue = dictionary[event.currentTarget] as CursorValue;
			if (value) setCursorByVO(value.cursor);
		}
		
		protected static function cursorOutHandler(event:Event):void {
			removeCurrentCursor();
		}
		
	}
}

// ---- CursorValue ----

import nl.mediamonkey.utils.CursorVO;
import nl.mediamonkey.utils.CursorUtil;

class CursorValue {
	
	public var cursor:CursorVO;
	public var overEvents:Array;
	public var outEvents:Array;
	
	public function CursorValue(cursor:CursorVO, overEvents:Array=null, outEvents:Array=null) {
		this.cursor = cursor;
		this.overEvents = (overEvents) ? overEvents : [CursorUtil.ROLL_OVER];
		this.outEvents = (outEvents) ? outEvents : [CursorUtil.ROLL_OUT];
	}
	
}