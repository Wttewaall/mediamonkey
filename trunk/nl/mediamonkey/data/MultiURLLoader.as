package nl.mediamonkey.data {
	
	/*
	To do:
	.	add source: URLLoader, ArrayCollection, Array etc.. 
	*/
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	
	import mx.collections.ArrayCollection;
	
	import nl.mediamonkey.events.MultiProgressEvent;
	
	[Event(name="open", type="flash.events.Event")]
	[Event(name="progress", type="flash.events.ProgressEvent")]
	[Event(name="complete", type="flash.events.Event")]
	[Event(name="cancel", type="flash.events.Event")]
	[Event(name="ioError", type="flash.events.IOErrorEvent")]
	[Event(name="securityError", type="flash.events.SecurityErrorEvent")]
	
	public class MultiURLLoader extends EventDispatcher {
		
		private var collection:ArrayCollection = new ArrayCollection();
		
		// ---- getters & setters ----
		
		public function get bytesLoaded():uint {
			var result:uint = 0;
			for (var i:uint=0; i<collection.length; i++) {
				result += collection.getItemAt(i).bytesLoaded as uint;
			}
			return result;
		}
		
		public function get bytesTotal():uint {
			var result:uint = 0;
			for (var i:uint=0; i<collection.length; i++) {
				result += collection.getItemAt(i).bytesTotal  as uint;
			}
			return result;
		}
		
		// ---- constructor ----
		
		public function MultiURLLoader(sources:Array=null) {
			//if (sources) setupLoaders(sources);
		}
		
		public function load(sources:Array=null):void {
			//if (sources) setupLoaders(sources);
			trace("load");
			
			var item:LoaderItem;
			for (var i:uint=0; i<sources.length; i++) {
				
				if (sources[i] is String) {
					item = new LoaderItem(new URLRequest(sources[i]));
					
				} else if (sources[i] is URLRequest) {
					item = new LoaderItem(sources[i]);
					
				} else {
					throw new ArgumentError("type must be either String or URLRequest");
				}
				
				trace(item.loader)
				item.loader.addEventListener(Event.OPEN, loaderOpenHandler, false, 0, true);
				item.loader.addEventListener(ProgressEvent.PROGRESS, loaderProgressHandler, false, 0, true);
				item.loader.addEventListener(Event.COMPLETE, loaderCompleteHandler, false, 0, true);
				item.loader.addEventListener(IOErrorEvent.IO_ERROR, loaderIOErrorHandler, false, 0, true);
				item.loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, loaderSecurityErrorHandler, false, 0, true);
				
				collection.addItem(item);
				item.loader.load(item.request); // start load
			}
		}
		
		public function cancel():void {
			for (var i:uint=0; i<collection.length; i++) {
				collection.getItemAt(i).loader.close();
			}
			dispatchEvent(new Event(Event.CANCEL));
		}
		
		// ---- protected methods ----
		
		/*protected function setupLoaders(sources:Array):void {
			collection = new ArrayCollection();
			
			var request:URLRequest;
			var loader:URLLoader;
			
			for (var i:uint=0; i<sources.length; i++) {
				request = new URLRequest(sources[i]);
				
				loader = new URLLoader();
				loader.addEventListener(Event.OPEN, loaderOpenHandler, false, 0, true);
				loader.addEventListener(ProgressEvent.PROGRESS, loaderProgressHandler, false, 0, true);
				loader.addEventListener(Event.COMPLETE, loaderCompleteHandler, false, 0, true);
				loader.addEventListener(IOErrorEvent.IO_ERROR, loaderIOErrorHandler, false, 0, true);
				loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, loaderSecurityErrorHandler, false, 0, true);
				
				collection.addItem(new LoaderItem(request, loader));
			}
		}*/
		
		protected function loaderOpenHandler(event:Event):void {
			var item:LoaderItem = getLoaderItemByLoader(event.target as URLLoader);
			trace("open");
			// delegate an open event of each URLLoader through a MultiProgressEvent
			dispatchEvent(new MultiProgressEvent(MultiProgressEvent.ITEM_OPEN, item.request, item.loader));
		}
		
		protected function loaderProgressHandler(event:ProgressEvent):void {
			var item:LoaderItem = getLoaderItemByLoader(event.target as URLLoader);
			
			// close stream on first progress event, wait for all loaders to be ready
			if (isNaN(item.bytesTotal) && event.bytesTotal > event.bytesLoaded) {
				item.loader.close();
				item.bytesLoaded = event.bytesLoaded;
				item.bytesTotal = event.bytesTotal;
				trace("close");
				
				if (loadersReady()) {
					load();
					// dispatch our own open event when all URLLoaders are opened
					dispatchEvent(new Event(Event.OPEN));
				}
				
			} else {
				item.bytesLoaded = event.bytesLoaded;
				item.bytesTotal = event.bytesTotal;
				trace("progress");
				
				// delegate a progress event of each URLLoader through a MultiProgressEvent
				dispatchEvent(new MultiProgressEvent(MultiProgressEvent.ITEM_PROGRESS, item.request, item.loader));
				
				// dispatch the accumulated bytesLoaded and bytesTotal of all loaders
				dispatchEvent(new ProgressEvent(ProgressEvent.PROGRESS, false, false, bytesLoaded, bytesTotal));
			}
		}
		
		protected function loaderCompleteHandler(event:Event):void {
			var item:LoaderItem = getLoaderItemByLoader(event.target as URLLoader);
			
			// delegate the complete event of each URLLoader through a MultiProgressEvent
			dispatchEvent(new MultiProgressEvent(MultiProgressEvent.ITEM_COMPLETE, item.request, item.loader));
			
			// dispatch our own complete event when all URLLoaders are complete
			if (loadersComplete()) dispatchEvent(new Event(Event.COMPLETE));
		}
		
		protected function loaderIOErrorHandler(event:IOErrorEvent):void {
			trace("IOErrorEvent "+event.text);
			dispatchEvent(event.clone());
		}
		
		protected function loaderSecurityErrorHandler(event:SecurityErrorEvent):void {
			trace("SecurityErrorEvent "+event.text);
			dispatchEvent(event.clone());
		}
		
		// ---- private methods ----
		
		private function loadersReady():Boolean {
			for (var i:uint=0; i<collection.length; i++) {
				var item:LoaderItem = collection.getItemAt(i) as LoaderItem;
				if (isNaN(item.bytesTotal)) return false;
			}
			return true;
		}
		
		private function loadersComplete():Boolean {
			for (var i:uint=0; i<collection.length; i++) {
				var item:LoaderItem = collection.getItemAt(i) as LoaderItem;
				if (item.bytesLoaded != item.bytesTotal) return false;
			}
			return true;
		}
		
		private function getLoaderItemByLoader(loader:URLLoader):LoaderItem {
			var item:LoaderItem;
			for (var i:uint=0; i<collection.length; i++) {
				item = collection.getItemAt(i) as LoaderItem;
				if (item.loader == loader) return item;
			}
			return null;
		}
		
	}
}

import flash.net.URLRequest;
import flash.net.URLLoader;

internal class LoaderItem {
	
	public var request:URLRequest;
	public var loader:URLLoader;
	public var bytesLoaded:Number;
	public var bytesTotal:Number;
	
	public function LoaderItem(request:URLRequest) {
		this.request = request;
		this.loader = new URLLoader();
	}
	
	public function load():void {
		loader.load(request);
	}
	
	public function toString():String {
		return "LoaderItem{url:"+request.url+"}";
	}
}