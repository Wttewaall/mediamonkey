package nl.mediamonkey.color {
	
	public class RGBColor extends Color {
		
		public static const MIN_VALUE	:Number = 0;
		public static const MAX_VALUE	:Number = 255;
		
		// ---- getters & setters ----
		
		private var _r		:uint;
		private var _g		:uint;
		private var _b		:uint;
		
		[Bindable]
		public function get r():uint {
			return _r;
		}
		
		public function set r(value:uint):void {
			if (_r != value) setProperties(value, g, b);
		}
		
		[Bindable]
		public function get g():uint {
			return _g;
		}
		
		public function set g(value:uint):void {
			if (_g != value) setProperties(r, value, b);
		}
		
		[Bindable]
		public function get b():uint {
			return _b;
		}
		
		public function set b(value:uint):void {
			if (_b != value) setProperties(r, g, value);
		}
		
		// ---- constructor ----
		
		public function RGBColor(red:uint=0, green:uint=0, blue:uint=0) {
			setProperties(red, green, blue);
		}
		
		// ---- protected methods ----
		
		protected function setProperties(r:uint, g:uint, b:uint, invalidate:Boolean=true):void {
			_r = Math.max(MIN_VALUE, Math.min(r, MAX_VALUE));
			_g = Math.max(MIN_VALUE, Math.min(g, MAX_VALUE));
			_b = Math.max(MIN_VALUE, Math.min(b, MAX_VALUE));
			
			if (invalidate) invalidateColorValue();
		}
		
		// ---- conversion methods ----
		
		public static function fromDecimal(value:uint):RGBColor {
			var color:RGBColor = new RGBColor();
			color.fromDecimal(value);
			return color;
		}
		
		override public function fromDecimal(value:uint):void {
			if (value < 0 || value > 0xFFFFFF)
				throw new ArgumentError("invalid value, input must be a value between 0 and 16777215");
			
			// let's trust the input, it saves us a toDecimal calculation
			setColorValue(value);
			setProperties(value >> 16 & 0xFF, value >> 8 & 0xFF, value & 0xFF, false);
		}
		
		override public function toDecimal():uint {
			return r << 16 | g << 8 | b;
		}
		
		override public function toString():String {
			return "[RGBColor r:"+r+" g:"+g+" b:"+b+"]";
		}
		
	}
}