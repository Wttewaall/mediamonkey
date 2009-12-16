package nl.mediamonkey.data {
	
	import br.com.stimuli.loading.BulkLoader;
	import br.com.stimuli.loading.loadingtypes.LoadingItem;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.ProgressEvent;
	
	[Event(name="complete", type="flash.events.Event")]
	[Event(name="progress", type="flash.events.ProgressEvent")]
	
	public class BulkloaderManager extends EventDispatcher {
		
		private var loaders:Array = new Array();
		
		// ---- getters & setters ----
		
		public function get bytesLoaded():uint {
			var bytes:uint = 0;
			
			var loader:BulkLoader;
			for each (loader in loaders) {
				bytes += loader.bytesLoaded;
			}
			
			return bytes;
		}
		
		public function get bytesTotal():uint {
			var bytes:uint = 0;
			var loader:BulkLoader;
			
			for each (loader in loaders) {
				for each (var item:LoadingItem in loader.items) {
					bytes += item.weight;
				}
			}
			
			return bytes;
		}
		
		public function get numLoaders():uint {
			return loaders.length;
		}
		
		// ---- Singleton ----
		
		private static const _instance:BulkloaderManager = new BulkloaderManager(SingletonLock);
		public static function get instance():BulkloaderManager { return _instance; }
		
		public function BulkloaderManager(lock:Class) {
			if (lock != SingletonLock) throw new Error("BulkloaderManager is singleton");
		}
		
		// ---- public methods ----
		
		public function addLoader(loader:BulkLoader):void {
			if (loaders.indexOf(loader) == -1) {
				loader.addEventListener(BulkLoader.COMPLETE, completeHandler);
				loader.addEventListener(BulkLoader.PROGRESS, progressHandler);
				loaders.push(loader);
			}
		}
		
		public function removeLoader(loader:BulkLoader):void {
			var index:int = loaders.indexOf(loader);
			if (index > -1) {
				loader = loaders.splice(index, 1);
				loader.removeEventListener(BulkLoader.COMPLETE, completeHandler);
				loader.removeEventListener(BulkLoader.PROGRESS, progressHandler);
			}
		}
		
		public function removeAllLoaders():void {
			var loader:BulkLoader;
			for each (loader in loaders) {
				loader.removeEventListener(BulkLoader.COMPLETE, completeHandler);
				loader.removeEventListener(BulkLoader.PROGRESS, progressHandler);
			}
			loaders = new Array();
		}
		
		// ---- protected methods ----
		
		protected function completeHandler(event:ProgressEvent):void {
			var loader:BulkLoader;
			
			/** TODO: check if a loader stalls on an IOError */
			for each (loader in loaders) {
				if (!loader.isFinished) return;
			}
			dispatchEvent(new Event(Event.COMPLETE));
		}
		
		protected function progressHandler(event:ProgressEvent):void {
			dispatchEvent(new ProgressEvent(ProgressEvent.PROGRESS, false, false, bytesLoaded, bytesTotal));
		}
		
	}
}

class SingletonLock {}