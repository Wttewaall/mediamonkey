package nl.mediamonkey.helpers {
	
	import flash.display.DisplayObject;
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
	
	/**
	 * TODO:
	 * selectedPage="{myThirdPage}" doesn't work yet
	 */
	
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
				
				var fromViewStack:Boolean = (selectedPageIndex == -1 && selectedPageIndex != viewstack.selectedIndex);
				update(fromViewStack);
				
				dispatchEvent(new ViewStackHelperEvent(ViewStackHelperEvent.VIEWSTACK_CHANGE, viewstack, selectedPageIndex, selectedPage));
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
				
				dispatchEvent(new ViewStackHelperEvent(ViewStackHelperEvent.SELECTED_PAGE_INDEX_CHANGE, viewstack, _selectedPageIndex, selectedPage));
				dispatchEvent(new ViewStackHelperEvent(ViewStackHelperEvent.SELECTED_PAGE_CHANGE, viewstack, _selectedPageIndex, selectedPage));
			}
		}
		
		public function get selectedPage():Container {
			if (!viewstack) return null;
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
				dispatchEvent(new ViewStackHelperEvent(ViewStackHelperEvent.HAS_NEXT_PAGE_CHANGE, viewstack, selectedPageIndex, selectedPage));
			}
		}
		
		public function get hasPreviousPage():Boolean {
			return _hasPreviousPage;
		}
		
		[Bindable("hasPreviousPageChange")]
		public function set hasPreviousPage(value:Boolean):void {
			if (_hasPreviousPage != value) {
				_hasPreviousPage = value;
				dispatchEvent(new ViewStackHelperEvent(ViewStackHelperEvent.HAS_PREVIOUS_PAGE_CHANGE, viewstack, selectedPageIndex, selectedPage));
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
				selectedPageIndex = viewstack.getChildIndex(child);
				return;
				
			} else {
				for (var i:uint=0; i<viewstack.numChildren; i++) {
					if (Container(viewstack.getChildAt(i)).label == name) {
						selectedPageIndex = i;
						return;
					}
				}
				
				trace("Could find no child with name:", name);
			}
		}
		
		public function getPageIndex(page:Container):int {
			return viewstack.getChildIndex(page);
		}
		
		// ---- protected methods ----
		
		protected function addListeners(dispatcher:IEventDispatcher):void {
			dispatcher.addEventListener(FlexEvent.INITIALIZE, viewstackInitializeHandler);
			dispatcher.addEventListener(FlexEvent.VALUE_COMMIT, viewstackValueCommitHandler);
			dispatcher.addEventListener(IndexChangedEvent.CHANGE, viewstackIndexChangedHandler);
		}
		
		protected function removeListeners(dispatcher:IEventDispatcher):void {
			dispatcher.removeEventListener(FlexEvent.INITIALIZE, viewstackInitializeHandler);
			dispatcher.removeEventListener(FlexEvent.VALUE_COMMIT, viewstackValueCommitHandler);
			dispatcher.removeEventListener(IndexChangedEvent.CHANGE, viewstackIndexChangedHandler);
		}
		
		protected function update(useViewStackProperties:Boolean=false):void {
			if (useViewStackProperties) {
				selectedPageIndex = viewstack.selectedIndex;
				
			} else {
				if (viewstack) viewstack.selectedIndex = selectedPageIndex;
				//else trace("no viewstack yet");
			}
			
			hasNextPage = (viewstack) ? (selectedPageIndex+1 < numPages) : false;
			hasPreviousPage = (viewstack) ? (selectedPageIndex-1 >= 0) : false;
		}
		
		// ---- event handlers ----
		
		protected function viewstackInitializeHandler(event:FlexEvent):void {
			update(selectedPageIndex != viewstack.selectedIndex);
		}
		
		protected function viewstackValueCommitHandler(event:FlexEvent):void {
			if (selectedPageIndex != viewstack.selectedIndex) {
				update(true);
			}
		}
		
		protected function viewstackIndexChangedHandler(event:IndexChangedEvent):void {
			if (selectedPageIndex != viewstack.selectedIndex) {
				update(true);
			}
		}
		
	}
}