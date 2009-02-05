package nl.mediamonkey.events {
	
	import flash.events.Event;
	
	public class ViewStackHelperEvent extends Event {
		
		public static const VIEWSTACK_CHANGE				:String = "viewstackChange";
		public static const SELECTED_PAGE_INDEX_CHANGE		:String = "selectedPageIndexChange";
		public static const SELECTED_PAGE_CHANGE			:String = "selectedPageChange";
		public static const HAS_NEXT_PAGE_CHANGE			:String = "hasNextPageChange";
		public static const HAS_PREVIOUS_PAGE_CHANGE		:String = "hasPreviousPageChange";
		
		public function ViewStackHelperEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false) {
			super(type, bubbles, cancelable);
		}
		
	}
}