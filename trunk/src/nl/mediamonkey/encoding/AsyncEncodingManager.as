package nl.mediamonkey.encoding {
	
	import by.blooddy.crypto.Base64;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.ProgressEvent;
	import flash.utils.ByteArray;
	
	import mx.logging.LogEvent;
	import mx.logging.LogEventLevel;
	
	import nl.mediamonkey.encoding.data.EncodingItem;
	import nl.mediamonkey.encoding.enum.ContentType;
	import nl.mediamonkey.encoding.events.JPEGAsyncCompleteEvent;
	
	[Event(name="init", type="flash.events.Event")]
	[Event(name="progress", type="flash.events.ProgressEvent")]
	[Event(name="change", type="flash.events.Event")]
	[Event(name="complete", type="flash.events.Event")]
	[Event(name="cancel", type="flash.events.Event")]
	[Event(name="clear", type="flash.events.Event")]
	[Event(name="error", type="flash.events.ErrorEvent")]
	[Event(name="log", type="mx.logging.LogEvent")]
	
	public class AsyncEncodingManager extends EventDispatcher {
		
		public var quality				:uint = 80;
		public var pixelsPerIteration	:uint = 1000;
		public var contentType			:String = ContentType.JPG;
		public var resumeAfterCancel	:Boolean = true;
		public var encodeBase64			:Boolean = true;
		
		protected var asyncEncoder		:JPEGAsyncEncoder;
		protected var items				:Vector.<EncodingItem>;
		protected var cursor			:int = -1;
		protected var working			:Boolean;
		protected var cancelling		:Boolean;
		
		// ---- getters & setters ----
		
		private var _bytesLoaded		:uint = 0;
		private var _bytesTotal			:uint = 0;
		private var _numCompleteItems	:uint = 0;
		private var _numPendingItems	:uint = 0;
		
		public function get bytesLoaded():uint {
			return _bytesLoaded;
		}
		
		public function get bytesTotal():uint {
			return _bytesTotal;
		}
		
		public function get currentIndex():int {
			return cursor;
		}
		
		public function get numTotalItems():uint {
			return items.length;
		}
		
		public function get numCompleteItems():uint {
			return _numCompleteItems;
		}
		
		public function get numPendingItems():uint {
			return _numPendingItems;
		}
		
		public function get completeItems():Vector.<EncodingItem> {
			var copy:Vector.<EncodingItem> = new Vector.<EncodingItem>();
			
			for (var i:int=0; i<items.length; i++) {
				if (items[i].bytes != null) copy.push(items[i]);
			}
			
			_numCompleteItems = copy.length;
			return copy;
		}
		
		public function get pendingItems():Vector.<EncodingItem> {
			var copy:Vector.<EncodingItem> = new Vector.<EncodingItem>();
			
			for (var i:int=0; i<items.length; i++) {
				if (items[i].bytes == null) copy.push(items[i]);
			}
			
			_numPendingItems = copy.length;
			return copy;
		}
		
		public function get allItems():Vector.<EncodingItem> {
			return items.concat();
		}
		
		// ---- constructor ----
		
		public function AsyncEncodingManager() {
			items = new Vector.<EncodingItem>();
		}
		
		// ---- public methods ----
		
		public function addImage(source:*):void {
			if (source == null) throw new TypeError("type is null");
			
			if (source is Bitmap) addBitmap(Bitmap(source));
			else if (source is BitmapData) addBitmapData(BitmapData(source));
			else if (source is EncodingItem) addEncodingItem(EncodingItem(source));
			//else if (source is ByteArray) addByteArray(ByteArray(source), null);
			else throw new TypeError("type not implemented");
		}
		
		public function addBitmap(source:Bitmap):void {
			if (source == null) throw new TypeError("type is null");
			if (!validateStates(true, true)) return;
			
			var item:EncodingItem = new EncodingItem(source.bitmapData.width, source.bitmapData.height, contentType);
			item.bitmapData = source.bitmapData;
			items.push(item);
			_numPendingItems++;
		}
		
		public function addBitmapData(source:BitmapData):void {
			if (source == null) throw new TypeError("type is null");
			if (!validateStates(true, true)) return;
			
			var item:EncodingItem = new EncodingItem(source.width, source.height, contentType);
			item.bitmapData = source;
			items.push(item);
			_numPendingItems++;
		}
		
		public function addEncodingItem(source:EncodingItem):void {
			if (source == null) throw new TypeError("type is null");
			if (!validateStates(true, true)) return;
			
			if (source.contentType == null) source.contentType = contentType;
			
			items.push(source);
			_numPendingItems++;
		}
		
		// TODO
		/*public function addByteArray(source:ByteArray, contentType:String, width:uint=0, height:uint=0):void {
			if (source == null) throw new TypeError("type is null");
			if (!validateStates(true, true)) return;
			
			// if these arguments are unknown, load the bytearray into a Loader and re-encode
			if (width == 0 || height == 0 || (contentType != ContentType.JPG && contentType != ContentType.PNG)) {
				var loader:Loader = new Loader();
				loader.loaderInfo.addEventListener(Event.COMPLETE, loaderCompleteHandler);
				loader.loadBytes(source);
			}
			
			items.push(new EncodingItem(0, 0, ""));
			_numPendingItems++;
		}*/
		
		public function start():Boolean {
			if (!validateStates(true, true)) return false;
			
			if (items.length == 0 || cursor >= items.length-1) {
				log("EncodingManager: nothing to encode");
				return false;
			}
			
			if (cursor > -1) {
				// resume from last complete encoding result
				if (resumeAfterCancel) cursor = findLastCompleteItemIndex();
				else clear();
			}
			
			working = true;
			dispatchEvent(new Event(Event.INIT));
			encode(++cursor);
			
			return true;
		}
		
		public function cancel():void {
			if (!validateStates(false, true)) return;
			
			if (working) {
				cancelling = true;
				asyncEncoder.cancel();
				
			} else {
				log("EncodingManager: nothing to cancel");
			}
		}
		
		public function clear():void {
			if (!validateStates(true, true)) {
				log("EncodingManager: cannot clear");
				return;
			}
			
			items = new Vector.<EncodingItem>();
			
			cursor = -1;
			working = false;
			cancelling = false;
			
			_bytesLoaded = 0;
			_bytesTotal = 0;
			_numCompleteItems = 0;
			_numPendingItems = 0;
			
			dispatchEvent(new Event(Event.CLEAR));
		}
		
		// ---- protected methods ----
		
		protected function encode(index:int):void {
			if (!asyncEncoder) {
				asyncEncoder = new JPEGAsyncEncoder(quality);
				asyncEncoder.PixelsPerIteration = pixelsPerIteration;
				asyncEncoder.addEventListener(ProgressEvent.PROGRESS, asyncProgressHandler);
				asyncEncoder.addEventListener(JPEGAsyncCompleteEvent.JPEGASYNC_COMPLETE, asyncCompleteHandler);
			}
			
			dispatchEvent(new Event(Event.CHANGE));
			var encoding:Boolean = asyncEncoder.encode(items[index].bitmapData);
			
			if (!encoding) dispatchEvent(new ErrorEvent(ErrorEvent.ERROR, false, false, "Error while encoding"));
		}
		
		protected function validateStates(validateWorking:Boolean, validateCancelling:Boolean):Boolean {
			if (validateWorking && working) {
				log("EncodingManager: still busy working");
				return false;
			}
			
			if (validateCancelling && cancelling) {
				log("EncodingManager: still busy cancelling");
				return false;
			}
			
			return true;
		}
		
		protected function log(...message:Array):void {
			dispatchEvent(new LogEvent(message.join(" "), LogEventLevel.INFO));
		}
		
		protected function findLastCompleteItemIndex():int {
			for (var i:int=0; i<items.length; i++) {
				if (items[i].bytes == null) return i-1;
			}
			return items.length - 1;
		}
		
		// ---- event handlers ----
		
		// TODO
		/*protected function loaderCompleteHandler(event:Event):void {
			var info:LoaderInfo = LoaderInfo(event.currentTarget);
			log(info.content.width, info.content.height, info.contentType);
		}*/
		
		protected function asyncProgressHandler(event:ProgressEvent):void {
			if (cancelling && event.bytesLoaded == 0 && event.bytesTotal == 0) return;
			
			// TODO: track real total bytes?
			_bytesLoaded = ((cursor + event.bytesLoaded/event.bytesTotal) / items.length) * 100;
			_bytesTotal = 100;
			
			dispatchEvent(new ProgressEvent(ProgressEvent.PROGRESS, false, false, _bytesLoaded, _bytesTotal));
		}
		
		protected function asyncCompleteHandler(event:JPEGAsyncCompleteEvent):void {
			
			if (event.ImageData == null) {
				cancelling = false;
				working = false;
				dispatchEvent(new Event(Event.CANCEL));
				return;
				
			} else {
				// TODO: track total bytes?
				log("EncodingManager: encoded", event.ImageData.length, "bytes");
				items[cursor].bytes = event.ImageData;
				_numCompleteItems++;
				_numPendingItems--;
				
				// optional
				if (encodeBase64) {
					items[cursor].base64 = Base64.encode(event.ImageData);
				}
			}
			
			if (cursor < items.length - 1) {
				encode(++cursor);
				
			} else {
				cancelling = false;
				working = false;
				dispatchEvent(new Event(Event.COMPLETE));
				return;
			}
		}
		
	}
}