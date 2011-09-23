package nl.mediamonkey.helpers.events {
	
	import flash.display.DisplayObject;
	import flash.events.Event;
	
	import mx.containers.ViewStack;
	import mx.core.Container;
	
	public class ViewStackHelperEvent extends Event {
		
		public static const VIEWSTACK_CHANGE				:String = "viewstackChange";
		public static const SELECTED_PAGE_INDEX_CHANGE		:String = "selectedPageIndexChange";
		public static const SELECTED_PAGE_CHANGE			:String = "selectedPageChange";
		public static const HAS_NEXT_PAGE_CHANGE			:String = "hasNextPageChange";
		public static const HAS_PREVIOUS_PAGE_CHANGE		:String = "hasPreviousPageChange";
		
		public var viewstack	:ViewStack;
		public var index		:int;
		public var page			:Container;
		
		public function ViewStackHelperEvent(type:String, viewstack:ViewStack, index:int, page:Container) {
			super(type, false, false);
			this.viewstack = viewstack;
			this.index = index;
			this.page = page;
		}
		
	}
}