package nl.mediamonkey.proxy {
	
	import flash.utils.Proxy;
	
	public dynamic class Document extends Proxy {
		
		// attribute values
		protected static const EXECUTE:uint = 1;
		protected static const WRITE:uint = 2;
		protected static const READ:uint = 4;
		
		public var type:String;
		public var created:Date;
		public var modified:Date;
		public var opened:Date;
		public var attributes:uint;
		
		// ---- getters & setters ----
		
		protected var _readOnly:Boolean;
		protected var _hidden:Boolean;
		protected var _archive:Boolean;
		
		public function get readOnly():Boolean { return _readOnly }
		public function set readOnly(value:Boolean):void { _readOnly = value }
		public function get hidden():Boolean { return _hidden }
		public function set hidden(value:Boolean):void { _hidden = value }
		public function get archive():Boolean { return _archive }
		public function set archive(value:Boolean):void { _archive = value }
		
		public function get attrib():int {
			return attributes;
		}
		
		public function set attrib(value:int):void {
			var input:String = new String();
			input += String(value).charAt(0);
			input += String(value).charAt(1);
			input += String(value).charAt(2);
			attributes = parseInt(input);
		}
		
		// ---- constructor ----
		
		public function Document(type:String, created:Date=null) {
			var currentDate:Date = new Date();
			
			if (created == null) created = currentDate;
			opened = currentDate;
			
			flags = new BitVector(3);
			attributes = new BitVector(3);
		}
		
		// ---- overrides ----
		
		flash_proxy override function callProperty(method:*, ...args):* {
			try { 		 
				var clazz:Class = getDefinitionByName(getQualifiedClassName(this)) as Class;
				return clazz.prototype[method].apply(method, args);
			} catch (e:Error) {
				return methodMissing(method, args);
			}
		}
		
		protected function methodMissing(method:*, args:Array):Object{
			throw(new Error("Method Missing"));
		}
		
		flash_proxy override function setProperty(prop:*, value:*):void {
			trace(name, "setProperty", prop, value);
			modified = new Date();
		}
		
	}
}