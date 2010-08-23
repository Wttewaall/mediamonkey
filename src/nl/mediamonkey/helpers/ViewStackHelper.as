package nl.mediamonkey.helpers {
	
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	import mx.containers.ViewStack;
	import mx.core.Container;
	import mx.core.IMXMLObject;
	import mx.events.FlexEvent;
	import mx.events.IndexChangedEvent;
	
	import nl.mediamonkey.helpers.events.ViewStackHelperEvent;
	
	[Event(name="viewstackChange",						type="nl.mediamonkey.helpers.events.ViewStackHelperEvent")]
	[Event(name="selectedPageIndexChange",				type="nl.mediamonkey.helpers.events.ViewStackHelperEvent")]
	[Event(name="selectedPageChange",					type="nl.mediamonkey.helpers.events.ViewStackHelperEvent")]
	[Event(name="hasNextPageChange",					type="nl.mediamonkey.helpers.events.ViewStackHelperEvent")]
	[Event(name="hasPreviousPageChange",				type="nl.mediamonkey.helpers.events.ViewStackHelperEvent")]
	
	public class ViewStackHelper extends EventDispatcher implements IMXMLObject {
		
		private var document:Object;
		
		// ---- getters & setters ----
		
		private var _viewstack:ViewStack;
		private var _selectedPageIndex:int = -1;
		private var _hasNextPage:Boolean;
		private var _hasPreviousPage:Boolean;
		
		/** viewStack **/
		
		public function get viewstack():ViewStack {
			return _viewstack;
		}
		
		
		[Bindable("viewstackChange")]
		public function set viewstack(value:ViewStack):void {
			if (_viewstack != value) {
				
				// if one exists, remove all listeners
				if (_viewstack != null) removeListeners(_viewstack);
				_viewstack = value;
				if (_viewstack != null)  addListeners(_viewstack);
				
				update(true);
				dispatchEvent(new ViewStackHelperEvent(ViewStackHelperEvent.VIEWSTACK_CHANGE));
			}
		}
		
		/** selectedPage **/
		
		public function get selectedPageIndex():int {
			return _selectedPageIndex;
		}
		
		[Bindable("selectedPageIndexChange")]
		public function set selectedPageIndex(value:int):void {
			if (_selectedPageIndex != value) {
				_selectedPageIndex = value;
				update();
				
				dispatchEvent(new ViewStackHelperEvent(ViewStackHelperEvent.SELECTED_PAGE_INDEX_CHANGE));
				dispatchEvent(new ViewStackHelperEvent(ViewStackHelperEvent.SELECTED_PAGE_CHANGE));
			}
		}
		
		public function get selectedPage():Container {
			return viewstack.getChildAt(selectedPageIndex) as Container;
		}
		
		[Bindable("selectedPageChange")]
		public function set selectedPage(value:Container):void {
			var index:int = viewstack.getChildIndex(value);
			if (_selectedPageIndex != index) {
				selectedPageIndex = index;
			}
		}
		
		/** getters **/
		
		public function get hasNextPage():Boolean {
			return _hasNextPage;
		}
		
		[Bindable("hasNextPageChange")]
		public function set hasNextPage(value:Boolean):void {
			if (_hasNextPage != value) {
				_hasNextPage = value;
				dispatchEvent(new ViewStackHelperEvent(ViewStackHelperEvent.HAS_NEXT_PAGE_CHANGE));
			}
		}
		
		public function get hasPreviousPage():Boolean {
			return _hasPreviousPage;
		}
		
		[Bindable("hasPreviousPageChange")]
		public function set hasPreviousPage(value:Boolean):void {
			if (_hasPreviousPage != value) {
				_hasPreviousPage = value;
				dispatchEvent(new ViewStackHelperEvent(ViewStackHelperEvent.HAS_PREVIOUS_PAGE_CHANGE));
			}
		}
		
		public function get numPages():int {
			return viewstack.numChildren;
		}
		
		// ---- constructor ----
		
		public function ViewStackHelper() {
			super();
		}
		
		// implemented IMXMLObject method
		public function initialized(document:Object, id:String):void {
			this.document = document;
		}
		
		// ---- public methods ----
		
		public function next():void {
			if (hasNextPage) {
				selectedPageIndex++;
				update();
			}
		}
		
		public function previous():void {
			if (hasPreviousPage) {
				selectedPageIndex--;
				update();
			}
		}
		
		public function gotoScreen(name:String):void {
			var child:DisplayObject = viewstack.getChildByName(name);
			if (child) {
				viewstack.selectedIndex = viewstack.getChildIndex(child);
				return;
				
			} else {
				for (var i:uint=0; i<viewstack.numChildren; i++) {
					if (Container(viewstack.getChildAt(i)).label == name) {
						viewstack.selectedIndex = i;
						return;
					}
				}
			}
			
			trace("Could find no child with name:", name);
		}
		
		public function getPageIndex(page:Container):int {
			return viewstack.getChildIndex(page);
		}
		
		// ---- protected methods ----
		
		protected function addListeners(dispatcher:IEventDispatcher):void {
			dispatcher.addEventListener(FlexEvent.INITIALIZE, viewstackInitHandler);
			dispatcher.addEventListener(IndexChangedEvent.CHANGE, viewstackChangeHandler);
		}
		
		protected function removeListeners(dispatcher:IEventDispatcher):void {
			dispatcher.removeEventListener(FlexEvent.INITIALIZE, viewstackInitHandler);
			dispatcher.removeEventListener(IndexChangedEvent.CHANGE, viewstackChangeHandler);
		}
		
		protected function update(useViewStackProperties:Boolean=false):void {
			if (useViewStackProperties) {
				selectedPageIndex = viewstack.selectedIndex;
			} else {
				viewstack.selectedIndex = selectedPageIndex;
			}
			hasNextPage = (viewstack) ? (selectedPageIndex+1 < numPages) : false;
			hasPreviousPage = (viewstack) ? (selectedPageIndex-1 >= 0) : false;
		}
		
		// ---- event handlers ----
		
		protected function viewstackInitHandler(event:Event):void {
			update(true);
		}
		
		protected function viewstackChangeHandler(event:IndexChangedEvent):void {
			update(true);
		}
		
	}
}