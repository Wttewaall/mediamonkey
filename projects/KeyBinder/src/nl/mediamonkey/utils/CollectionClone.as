/*
Original by Tink Ltd - http://www.tink.ws (Copyright (c) 2009)
*/

package nl.mediamonkey.utils {
	
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
	import mx.events.PropertyChangeEvent;

	public class CollectionClone extends EventDispatcher {
		
		private var _iterator			:IViewCursor;
		private var _collection			:ICollectionView;
		private var _outputCollection	:ArrayCollection;
		
		// ---- getters & setters ----
		
		[Bindable(event="collectionChange")]
		public function get dataProvider():Object {
			return _outputCollection;
		}
		
		public function set dataProvider(value:Object):void {
			
			if (value is Array) {
				_collection = new ArrayCollection(value as Array);
				
			} else if (value is ICollectionView) {
				_collection = value as ICollectionView;
				
			} else if (value is IList) {
				_collection = new ListCollectionView(value as IList);
				
			} else if (value is XMLList) {
				_collection = new XMLListCollection(value as XMLList);
				
			} else {
				_collection = new ArrayCollection([value]);
			}
			
			_iterator = _collection.createCursor();
			_collection.addEventListener(CollectionEvent.COLLECTION_CHANGE, collectionChangeHandler, false, 0, true);
			
			applyOutput(CollectionEventKind.RESET);
		}
		
		// ---- constructor ----
		
		public function CollectionClone() {
			_outputCollection = new ArrayCollection();
		}
		
		// ---- event handlers ----
		
		private function collectionChangeHandler(event:CollectionEvent):void {
			var i:uint;
			var numItems:uint;
			var item:Object;
			var propertyChangeEvent:PropertyChangeEvent;
			
			switch(event.kind) {
				case CollectionEventKind.ADD: {
					numItems = event.items.length;
					for (i=0; i<numItems; i++) {
						_outputCollection.addItemAt(event.items[i], event.location + i);
					}
					break;
				}
				case CollectionEventKind.MOVE: {
					numItems = event.items.length;
					for (i=0; i<numItems; i++) {
						item = _outputCollection.removeItemAt(event.oldLocation + i);
						_outputCollection.addItemAt(item, event.location + i);
					}
					break;
				}
				case CollectionEventKind.REFRESH:
				case CollectionEventKind.RESET: {
					applyOutput(event.kind);
					break;
				}
				case CollectionEventKind.REMOVE: {
					numItems = event.items.length;
					for (i=0; i<numItems; i++) {
						_outputCollection.removeItemAt(event.location + i);
					}
					break;
				}
				case CollectionEventKind.REPLACE: {
					numItems = event.items.length;
					for (i=0; i<numItems; i++) {
						propertyChangeEvent = PropertyChangeEvent(event.items[i]);
						_outputCollection.setItemAt(propertyChangeEvent.source, event.location + i);
					}
					break;
				}
				case CollectionEventKind.UPDATE: {
					numItems = event.items.length;
					for (i=0; i<numItems; i++) {
						propertyChangeEvent = PropertyChangeEvent(event.items[i]);
						_outputCollection.itemUpdated(propertyChangeEvent.source, propertyChangeEvent.property, propertyChangeEvent.oldValue, propertyChangeEvent.newValue); 
					}
					break;
				}
			}
		}
		
		// ---- private methods ----
		
		private function applyOutput(kind:String):void {
			_outputCollection = new ArrayCollection();
			var numItems:uint = _collection.length;
			for (var i:uint=0; i<numItems; i++) {
				_iterator.seek(CursorBookmark.FIRST, i, 0);
				_outputCollection.addItem(_iterator.current);
			}
			
			dispatchEvent(new CollectionEvent(CollectionEvent.COLLECTION_CHANGE, false, false, kind));
		}
	}
}