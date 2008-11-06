package nl.mediamonkey.data {
	
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.events.TimerEvent;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.utils.Timer;
	import flash.utils.getTimer;
	import flash.xml.XMLDocument;
	
	[Event(name="progress", type="flash.events.ProgressEvent")]
	[Event(name="complete", type="flash.events.Event")]
	[Event(name="error", type="flash.events.ErrorEvent")]
	
	public class SimpleService extends EventDispatcher {
		
		public static const RESULT_FORMAT_ARRAY			:String = "array";
		public static const RESULT_FORMAT_E4X			:String = "e4x";
		public static const RESULT_FORMAT_FLASHVARS		:String = "flashvars";
		public static const RESULT_FORMAT_OBJECT		:String = "object";
		public static const RESULT_FORMAT_TEXT			:String = "text";
		public static const RESULT_FORMAT_XML			:String = "xml";
		
		public static var ERROR_IO_MESSAGE				:String = "io";
		public static var ERROR_SECURITY_MESSAGE		:String = "security";
		public static var ERROR_TIMEOUT_MESSAGE			:String = "timeout";
		
		protected var _url								:String;
		protected var _method							:String;
		protected var _dataFormat						:String;
		protected var _resultFormat						:String;
		protected var _requestTimeout					:uint;
		protected var _result							:Object;
		
		protected var loader							:URLLoader;
		protected var timer								:Timer;
		protected var currentTime						:uint;
		protected var startTime							:uint;
		//protected var rootURL							:String;
		
		// ---- getters & setters ----
		
		public function get url():String {
			//if (rootURL) return buildPath(rootURL, _url);
			//else return _url;
			return _url;
		}
		
		public function set url(value:String):void {
			_url = value;
		}
		
		public function get method():String {
			return _method;
		}
		
		public function set method(value:String):void {
			switch (value) {
				case URLRequestMethod.GET:
				case URLRequestMethod.POST:
					_method = value;
					break;
				default:
					throw new ArgumentError("method is invalid");
			}
		}
		
		public function get resultFormat():String {
			return _resultFormat;
		}
		
		public function set resultFormat(value:String):void {
			switch (value) {
				case RESULT_FORMAT_ARRAY:
				case RESULT_FORMAT_FLASHVARS:
				case RESULT_FORMAT_OBJECT:
					_dataFormat = URLLoaderDataFormat.VARIABLES;
					break;
				case RESULT_FORMAT_E4X:
				case RESULT_FORMAT_TEXT:
				case RESULT_FORMAT_XML:
					_dataFormat = URLLoaderDataFormat.TEXT;
					break;
				default:
					throw new ArgumentError("resultFormat is invalid");
			}
			
			_resultFormat = value;
		}
		
		public function get requestTimeout():uint {
			return _requestTimeout;
		}
		
		public function set requestTimeout(value:uint):void {
			_requestTimeout = value;
			timer.delay = value;
		}
		
		// ---- getters only ----
		
		public function get dataFormat():String {
			return _dataFormat;
		}
		
		public function get result():Object {
			return _result;
		}
		
		public function get bytesLoaded():uint {
			return loader.bytesLoaded;
		}
		
		public function get bytesTotal():uint {
			return loader.bytesTotal;
		}
		
		// ---- constructor ----
		
		public function SimpleService(rootURL:String=null) {
			//this.rootURL = rootURL;
			this.url = rootURL;
			_method = URLRequestMethod.POST;
			_dataFormat = URLLoaderDataFormat.TEXT;
			
			loader = new URLLoader();
			loader.addEventListener(Event.OPEN, loaderOpenHandler);
			loader.addEventListener(ProgressEvent.PROGRESS, loaderProgressHandler);
			loader.addEventListener(Event.COMPLETE, loaderCompleteHandler);
			loader.addEventListener(IOErrorEvent.IO_ERROR, loaderIOErrorHandler);
			loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, loaderSecurityErrorHandler);
			
			timer = new Timer(requestTimeout);
			timer.addEventListener(TimerEvent.TIMER_COMPLETE, timerCompleteHandler);
		}
		
		public function send(parameters:Object=null):void {
			if (!url) return;
			
			loader.dataFormat = dataFormat;
			
			var request:URLRequest = new URLRequest(url);
			request.method = method;
			request.data = parameters;
			load(request);
		}
		
		protected function load(request:URLRequest):void {
			startTime = getTimer();
			timer.start();
			loader.load(request);
		}
		
		public function cancel():void {
			loader.close();
		}
		
		// ---- protected methods ----
		
		protected function loaderOpenHandler(event:Event):void {
			timer.reset();
		}
		
		protected function loaderProgressHandler(event:ProgressEvent):void {
			dispatchEvent(new ProgressEvent(ProgressEvent.PROGRESS, false, false, bytesLoaded, bytesTotal));
		}
		
		protected function loaderCompleteHandler(event:Event):void {
			switch (resultFormat) {
				case RESULT_FORMAT_ARRAY:
				case RESULT_FORMAT_FLASHVARS:
				case RESULT_FORMAT_TEXT:
				case RESULT_FORMAT_OBJECT: {
					_result = event.target.data;
					break;
				}
				case RESULT_FORMAT_E4X: {
					_result = XML(event.target.data);
					break;
				}
				case RESULT_FORMAT_XML: {
					_result = XMLDocument(event.target.data);
					break;
				}
			}
			
			dispatchEvent(new Event(Event.COMPLETE));
		}
		
		protected function loaderIOErrorHandler(event:IOErrorEvent):void {
			var message:String = ERROR_IO_MESSAGE + "\n" + event.text;
			dispatchEvent(new ErrorEvent(ErrorEvent.ERROR, false, false, message));
		}
		
		protected function loaderSecurityErrorHandler(event:SecurityErrorEvent):void {
			var message:String = ERROR_SECURITY_MESSAGE + "\n" + event.text;
			dispatchEvent(new ErrorEvent(ErrorEvent.ERROR, false, false, message));
		}
		
		protected function timerCompleteHandler(event:TimerEvent):void {
			dispatchEvent(new ErrorEvent(ErrorEvent.ERROR, false, false, ERROR_TIMEOUT_MESSAGE));
		}
		
		// ---- private methods ----
		
		/*private function buildPath(base:String, path:String):String {
			var backslash:String = "\\";
			var slash:String = "/";
			
			// convert all back slashes to forward slashes
			base = base.split(backslash).join(slash);
			path = path.split(backslash).join(slash);
			
			var baseSlash:Boolean = (base.charAt(base.length-1) == slash);
			var pathSlash:Boolean = (path.charAt(0) == slash);
			
			if (baseSlash) {
				return (pathSlash) ? base + path.substr(1) : base + path;
				
			} else {
				return (pathSlash) ? base + path : base + slash + path;
			}
		}*/
		
	}
}