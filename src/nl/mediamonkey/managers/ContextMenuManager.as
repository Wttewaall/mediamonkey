package nl.mediamonkey.managers {
	
	import flash.display.InteractiveObject;
	import flash.display.MovieClip;
	import flash.events.ContextMenuEvent;
	import flash.events.EventDispatcher;
	import flash.ui.ContextMenu;
	import flash.ui.ContextMenuBuiltInItems;
	import flash.ui.ContextMenuItem;
	import flash.utils.Dictionary;
	
	import mx.core.ApplicationGlobals;
	import mx.managers.ISystemManager;
	
	[Event(name="menuSelect", type="flash.events.ContextMenuEvent")]
	[Event(name="menuItemSelect", type="flash.events.ContextMenuEvent")]
	
	public class ContextMenuManager extends EventDispatcher	{
		
		protected var contextMenu	:ContextMenu = new ContextMenu();
		protected var dictionary	:Dictionary = new Dictionary(true);
		
		public static const neverAllowed:Array = ["Adobe", "Macromedia", "Flash Player", "Settings"];
		public static const disallowed:Array = [
			"Save", "Zoom In", "Zoom Out", "100%", "Show All", "Quality", "Play", "Loop", "Rewind",
			"Forward", "Back", "Movie not loaded", "About", "Print", "Show Redraw Regions",	"Debugger",
			"Undo", "Cut", "Copy", "Paste", "Delete", "Select All", "Open", "Open in new window", "Copy link"
		];
		
		public function get builtInItems():ContextMenuBuiltInItems {
			return contextMenu.builtInItems;
		}
		
		public function set builtInItems(value:ContextMenuBuiltInItems):void {
			if (value == null) contextMenu.hideBuiltInItems();
			else contextMenu.builtInItems = value;
		}
		
		public function get customItems():Array {
			return contextMenu.customItems;
		}
		
		public function set customItems(value:Array):void {
			for (var i:uint=0; i<value.length; i++) {
				if (value[i] is ContextMenuItem)
					contextMenu.customItems.push(value[i]);
				else throw new Error("input is not of type ContextMenuItem");
			}
		}
		
		// ---- constructor ----
		
		public function ContextMenuManager(object:InteractiveObject, builtInItems:ContextMenuBuiltInItems=null) {
			contextMenu.addEventListener(ContextMenuEvent.MENU_SELECT, delegateMenuEventHandler);
			object.contextMenu = contextMenu;
			this.builtInItems = builtInItems;
		}
		
		// ---- public static methods ----
		
		public static function setSystemManagerContextMenu(contextMenu:ContextMenu=null):void {
			// Remove ContextMenu from all SystemManager Menu items and PopUp
			// see: http://www.adobe.com/cfusion/communityengine/index.cfm?event=showdetails&productId=2&postId=2201
			var systemManager:ISystemManager = ApplicationGlobals.application.systemManager;
			MovieClip(systemManager).contextMenu = (contextMenu) ? contextMenu : new ContextMenu();
		}
		
		// ---- public methods ----
		
		public function createItem(caption:String, seperatorBefore:Boolean=false, enabled:Boolean=true, visible:Boolean=true, handler:Function=null):ContextMenuItem {
			var item:ContextMenuItem = new ContextMenuItem(caption, seperatorBefore, enabled, visible);
			return addItemAt(item, handler);
		}
		
		
		public function addItem(item:ContextMenuItem, handler:Function=null):ContextMenuItem {
			return addItemAt(item, handler);
		}
		
		public function addItemAt(item:ContextMenuItem, handler:Function=null, index:int=-1):ContextMenuItem {
			if (containsCaption(item.caption)) return null;
			if (!isValidCaption(item.caption))
				throw new Error("ContextMenuItem::caption \""+item.caption+"\" is not valid");
			
			item.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, delegateMenuItemEventHandler);
			dictionary[item.caption] = new HandlerItem(item, handler);
			
			if (index == -1 || index > contextMenu.customItems.length-1) {
				contextMenu.customItems.push(item);
			} else {
				contextMenu.customItems.splice(index, 0, item);
			}
			
			return item;
		}
		
		public function getItemIndex(item:ContextMenuItem):int {
			for (var i:uint=0; i<contextMenu.customItems.length; i++) {
				if (contextMenu.customItems[i] === item) return i;
			}
			return -1;
		}
		
		public function getItemAt(index:int):ContextMenuItem {
			return contextMenu.customItems[index] as ContextMenuItem;
		}
		
		public function getItemByCaption(caption:String):ContextMenuItem {
			if (containsCaption(caption)) {
				var handlerItem:HandlerItem = dictionary[caption] as HandlerItem;
				return handlerItem.item;
			}
			return null;
		}
		
		public function removeItem(item:ContextMenuItem):void {
			var index:int = getItemIndex(item);
			if (index > -1) removeItemAt(index);
		}
		
		public function removeItemAt(index:int):void {
			var item:ContextMenuItem = getItemAt(index);
			
			var handlerItem:HandlerItem = dictionary[item.caption] as HandlerItem;
			handlerItem.item.removeEventListener(ContextMenuEvent.MENU_ITEM_SELECT, handlerItem.handler);
			
			contextMenu.customItems.splice(index, 1);
			delete dictionary[item.caption];
		}
		
		public function removeAll():void {
			contextMenu.customItems = new Array();
			dictionary = new Dictionary(true);
		}
		
		// ---- protected methods ----
		
		protected function delegateMenuEventHandler(event:ContextMenuEvent):void {
			dispatchEvent(new ContextMenuEvent(ContextMenuEvent.MENU_SELECT));
		}
		
		protected function delegateMenuItemEventHandler(event:ContextMenuEvent):void {
			var item:ContextMenuItem = event.target as ContextMenuItem;
			var handlerItem:HandlerItem = getHandlerItemByCaption(item.caption);
			
			if (handlerItem.handler != null)
				handlerItem.handler.call(this, event);
			
			dispatchEvent(event);
		}
		
		protected function containsCaption(caption:String):Boolean {
			return (dictionary[caption] != null);
		}
		
		protected function getHandlerItemByCaption(caption:String):HandlerItem {
			return dictionary[caption] as HandlerItem;
		}
		
		/**
		 * 1. neverAllowed: any word is case insensitive
		 * 2. disallowed: first word is case insensitive, any next word is case sensitive
		 */
		protected function isValidCaption(caption:String):Boolean {
			
			for (var i:uint=0; i<neverAllowed.length; i++) {
				// test case insensitive word in any combination in caption
				if (new RegExp(neverAllowed[i], "ig").test(caption)) {
					return false;
				}
			}
			
			var captionWords:Array = caption.match(/\w+/g);
			var firstCaptionWord:String = captionWords[0];
			
			for (var j:uint=0; j<disallowed.length; j++) {
				var sentence:String = disallowed[j];
				var firstSentenceWord:String = sentence.match(/^\w*/)[0];
				
				// test first word
				if (new RegExp(firstSentenceWord, "ig").test(firstCaptionWord)) {
					
					// no more words
					if (captionWords.length == 1) {
						return false;
						
					} else {
						// get anything except the first word
						var restCaption:String = caption.replace(/(^\w*)|(\w.*)/g, "$2");
						var restSentence:String = sentence.replace(/(^\w*)|(\w.*)/g, "$2");
						
						// test rest chars in caption as first part of rest in sentence
						if (new RegExp("^"+restCaption+"+", "").test(restSentence)) {
							return false;
						}
					}
				}
			}
			
			return true;
		}
		
	}
}

import flash.ui.ContextMenuItem;

internal class HandlerItem {
	
	public var item:ContextMenuItem;
	public var handler:Function;
	
	public function HandlerItem(item:ContextMenuItem, handler:Function) {
		this.item = item;
		this.handler = handler;
	}
}