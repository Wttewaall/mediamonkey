package nl.mediamonkey.data {
	
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	
	import mx.collections.ArrayCollection;
	import mx.events.CollectionEvent;
	
	public class MultiServiceLoader extends MultiURLLoader {
		
		private var collection:ArrayCollection;
		
		// ---- constructor ----
		
		public function MultiServiceLoader(source:ArrayCollection=null) {
			if (source) setupServices(source);
		}
		
		public function load(source:ArrayCollection=null):void {
			if (source) setupServices(source);
			
			// start load
			for (var i:uint=0; i<collection.length; i++) {
				collection.getItemAt(i).load();
			}
		}
		
		public function cancel():void {
			for (var i:uint=0; i<collection.length; i++) {
				collection.getItemAt(i).cancel();
			}
			dispatchEvent(new Event(Event.CANCEL));
		}
		
		// ---- protected methods ----
		
		protected function setupServices(source:ArrayCollection):void {
			collection = new ArrayCollection();
			
			var service:SimpleService;
			
			for (var i:uint=0; i<source.length; i++) {
				service = source.getItemAt(i) as SimpleService;
				
				service.addEventListener(Event.OPEN, serviceOpenHandler, false, 0, true);
				service.addEventListener(ProgressEvent.PROGRESS, serviceProgressHandler, false, 0, true);
				service.addEventListener(Event.COMPLETE, serviceCompleteHandler, false, 0, true);
				service.addEventListener(IOErrorEvent.IO_ERROR, serviceIOErrorHandler, false, 0, true);
				service.addEventListener(SecurityErrorEvent.SECURITY_ERROR, serviceSecurityErrorHandler, false, 0, true);
			}
			
			collection.addItem(service);
		}
		
	}
}