package nl.mediamonkey.data {
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	import mx.collections.ArrayCollection;
	import mx.collections.CursorBookmark;
	import mx.collections.ICollectionView;
	import mx.collections.IList;
	import mx.collections.IViewCursor;
	import mx.collections.ListCollectionView;
	import mx.collections.XMLListCollection;
	import mx.events.CollectionEvent;
	import mx.events.CollectionEventKind;
	import mx.events.FlexEvent;
	import mx.utils.UIDUtil;
	
	[Event(name="change", type="flash.events.Event")]
	[Event(name="collectionChange", type="mx.events.CollectionEvent")]
	[Event(name="value_commit", type="mx.events.FlexEvent")]
	
	[DefaultProperty("data")]
	
	[Bindable]
	public class DataProvider extends EventDispatcher {
		
		private var collection:ICollectionView;
		private var iterator:IViewCursor;
		private var selectedUID:String;
		private var selectionChanged:Boolean = false;
		
		// bindable change variables
		public var selectedIndexChanged:Boolean = false;
    	public var selectedItemChanged:Boolean = false;
		
		// ---- getters & setters ----
		
		private var _selectedIndex:int = -1;
		private var _selectedItem:Object;
		
		public function get data():Object {
			//if (collection == null) collection = new ArrayCollection();
			return collection;
		}
		
		[Bindable("collectionChange")]
		public function set data(value:Object):void {
			setData(value);
			
			var event:CollectionEvent = new CollectionEvent(CollectionEvent.COLLECTION_CHANGE);
			event.kind = CollectionEventKind.RESET;
			collectionChangeHandler(event);
		}
		
		public function get selectedIndex():int {
			return _selectedIndex;
		}
		
		[Bindable("change")]
		public function set selectedIndex(value:int):void {
			setSelectedIndex(value);
			dispatchEvent(new Event(Event.CHANGE));
		}
		
		public function get selectedItem():Object {
			return _selectedItem;
		}
		
		[Bindable("change")]
		public function set selectedItem(data:Object):void {
			setSelectedItem(data);
			dispatchEvent(new Event(Event.CHANGE));
		}
		
		// ---- constructor ----
		
		public function DataProvider() {
			collection = new ArrayCollection();
		}
		
		// ---- public methods ----
		
		public function getItemIndex(item:Object):int {
			for (var i:uint=0; i<collection.length; i++) {
				if (collection[i] === item) return i;
			}
			return -1;
		}
		
		// ---- protected methods ----
		
		protected function setData(value:Object):void {
			
			if (collection) { // remove old collection
				collection.removeEventListener(CollectionEvent.COLLECTION_CHANGE, collectionChangeHandler, false);
				collection = null;
				iterator = null;
			}
			
			if (value is Array) collection = new ArrayCollection(value as Array);
			else if (value is ICollectionView) collection = ICollectionView(value);
			else if (value is IList) collection = new ListCollectionView(IList(value));
			else if (value is XMLList) collection = new XMLListCollection(value as XMLList);
			else if (value is XML) {
				var xmlList:XMLList = new XMLList();
				xmlList += value;
				collection = new XMLListCollection(xmlList);
			}
			else if (value != null) { // convert it to an array containing this one item
				var tmp:Array = [value];
				collection = new ArrayCollection(tmp);
			}
			
			if (collection) { // add listener with weak reference
				collection.addEventListener(CollectionEvent.COLLECTION_CHANGE, collectionChangeHandler, false, 0, true);
				iterator = collection.createCursor();
			}
		}
		
		protected function setSelectedIndex(value:int):void {
			_selectedIndex = value;
			if (value == -1) {
				_selectedItem = null;
				selectedUID = null;
			}
			
			//2 code paths: one for before collection, one after
			if (!collection || collection.length == 0) {
				selectedIndexChanged = true;
			} else {
				if (value != -1) {
					value = Math.min(value, collection.length - 1);
					if (!iterator) iterator = collection.createCursor();
					var bookmark:CursorBookmark = iterator.bookmark;
					var len:int = value;
					iterator.seek(CursorBookmark.FIRST, len);
					var data:Object = iterator.current;
					var uid:String = itemToUID(data);
					iterator.seek(bookmark, 0);
					_selectedIndex = value;
					_selectedItem = data;
					selectedUID = uid;
				}
			}
			
			selectionChanged = true;
			
			dispatchEvent(new FlexEvent(FlexEvent.VALUE_COMMIT));
		}
		
		protected function setSelectedItem(data:Object, clearFirst:Boolean=true):void {
			//2 code paths: one for before collection, one after
			if (!collection || collection.length == 0) {
				_selectedItem = data;
				selectedItemChanged = true;
				return;
			}
	
			var found:Boolean = false;
			var listCursor:IViewCursor = collection.createCursor();
			var i:int = 0;
			do {
				if (data == listCursor.current) {
					_selectedIndex = i;
					_selectedItem = data;
					selectedUID = itemToUID(data);
					selectionChanged = true;
					found = true;
					break;
				}
				i++;
			}
			while (listCursor.moveNext());
	
			if (!found) {
				selectedIndex = -1;
				_selectedItem = null;
				selectedUID = null;
			}
		}
		
		protected function collectionChangeHandler(event:CollectionEvent):void {
			var requiresValueCommit:Boolean = false;
			var len:Number;
			var ind:Object;
			
			var ce:CollectionEvent = CollectionEvent(event);
			if (ce.kind == CollectionEventKind.ADD) {
				if (selectedIndex >= ce.location) _selectedIndex++;
			}
			
			if (ce.kind == CollectionEventKind.REMOVE) {
				
				for (var i:int = 0; i < ce.items.length; i++) {
					var uid:String = itemToUID(ce.items[i]);
					if (selectedUID == uid) selectionChanged = true;
				}
				
				if (selectionChanged) {
					if (_selectedIndex >= collection.length)
						_selectedIndex = collection.length - 1;

					selectedIndexChanged = true;
					requiresValueCommit = true;
					
				} else if (selectedIndex >= ce.location) {
					_selectedIndex--;
					selectedIndexChanged = true;
					requiresValueCommit = true;
				}
			}
			
			if (ce.kind == CollectionEventKind.REFRESH) {
				selectedItemChanged = true;
				// Sorting always changes the selection array
				requiresValueCommit = true;
			}
			
			// delegate the CollectionEvent 
			dispatchEvent(event.clone());
			
			if (selectedIndexChanged || selectedItemChanged)
				dispatchEvent(new Event(Event.CHANGE));
			
			if (requiresValueCommit)
				dispatchEvent(new FlexEvent(FlexEvent.VALUE_COMMIT));
		}
		
		protected function itemToUID(data:Object):String {
			if (!data) return "null";
			return UIDUtil.getUID(data);
		}
		
	}
}