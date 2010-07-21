package nl.mediamonkey.color {
	
	public class RGBColor extends Color {
		
		public static const MIN_VALUE	:Number = 0;
		public static const MAX_VALUE	:Number = 100;
		
		// ---- getters & setters ----
		
		private var _r			:uint; // 0 to 255
		private var _g			:uint; // 0 to 255
		private var _b			:uint; // 0 to 255
		
		public function get r():uint {
			return _r;
		}
		
		public function set r(value:uint):void {
			if (_r != value) {
				setProperties(value, g, b);
				setColorValue(toDecimal());
			}
		}
		
		public function get g():uint {
			return _g;
		}
		
		public function set g(value:uint):void {
			if (_g != value) {
				setProperties(r, value, b);
				setColorValue(toDecimal());
			}
		}
		
		public function get b():uint {
			return _b;
		}
		
		public function set b(value:uint):void {
			if (_b != value) {
				setProperties(r, g, value);
				setColorValue(toDecimal());
			}
		}
		
		// ---- constructor ----
		
		public function RGBColor(red:uint=0, green:uint=0, blue:uint=0) {
			setProperties(red, green, blue);
			setColorValue(toDecimal());
		}
		
		// ---- protected methods ----
		
		protected function setProperties(r:uint, g:uint, b:uint):void {
			_r = Math.max(MIN_VALUE, Math.min(r, MAX_VALUE));
			_g = Math.max(MIN_VALUE, Math.min(g, MAX_VALUE));
			_b = Math.max(MIN_VALUE, Math.min(b, MAX_VALUE));
		}
		
		// ---- conversion methods ----
		
		public static function fromDecimal(value:uint):RGBColor {
			var color:RGBColor = new RGBColor();
			color.fromDecimal(value);
			return color;
		}
		
		override public function fromDecimal(value:uint):void {
			setColorValue(value);
			
			if (value < 0 || value > 0xFFFFFF)
				throw new ArgumentError("invalid value, input must be a value between 0 and 16777215");
			
			// fix? red mogelijk niet v>>16&0xFF
			setProperties(value >> 16 & 0xFF, value >> 8 & 0xFF, value & 0xFF);
		}
		
		override public function toDecimal():uint {
			return r << 16 | g << 8 | b;
		}
		
		override public function toString():String {
			return "[RGBColor r:"+r+" g:"+g+" b:"+b+"]";
		}
		
	}
}