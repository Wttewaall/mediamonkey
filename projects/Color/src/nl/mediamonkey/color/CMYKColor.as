package nl.mediamonkey.color {
	import nl.mediamonkey.color.utils.ColorUtil;
	
	
	public class CMYKColor extends Color {
		
		public static const MIN_VALUE	:Number = 0;
		public static const MAX_VALUE	:Number = 100;
		
		// ---- getters & setters ----
		
		private var _c			:Number;		// 0 to 100 cyan in percentage
		private var _m			:Number;		// 0 to 100 magenta in percentage
		private var _y			:Number;		// 0 to 100 yellow in percentage
		private var _k			:Number;		// 0 to 100 key (black) in percentage
		
		public function get c():Number {
			return _c;
		}
		
		public function set c(value:Number):void {
			if (_c != value) {
				setProperties(value, m, y, k);
				setColorValue(toDecimal());
			}
		}
		
		public function get m():Number {
			return _m;
		}
		
		public function set m(value:Number):void {
			if (_m != value) {
				setProperties(c, value, y, k);
				setColorValue(toDecimal());
			}
		}
		
		public function get y():Number {
			return _y;
		}
		
		public function set y(value:Number):void {
			if (_y != value) {
				setProperties(c, m, value, k);
				setColorValue(toDecimal());
			}
		}
		
		public function get k():Number {
			return _k;
		}
		
		public function set k(value:Number):void {
			if (_k != value) {
				setProperties(c, m, y, value);
				setColorValue(toDecimal());
			}
		}
		
		// ---- constructor ----
		
		public function CMYKColor(cyan:Number=0, magenta:Number=0, yellow:Number=0, black:Number=0) {
			setProperties(cyan, magenta, yellow, black);
			setColorValue(toDecimal());
		}
		
		// ---- protected methods ----
		
		protected function setProperties(c:Number, m:Number, y:Number, k:Number):void {
			_c = Math.max(MIN_VALUE, Math.min(c, MAX_VALUE));
			_m = Math.max(MIN_VALUE, Math.min(m, MAX_VALUE));
			_y = Math.max(MIN_VALUE, Math.min(y, MAX_VALUE));
			_k = Math.max(MIN_VALUE, Math.min(k, MAX_VALUE));
		}
		
		// ---- conversion methods ----
		
		public static function fromDecimal(value:uint):CMYKColor {
			var color:CMYKColor = new CMYKColor();
			color.fromDecimal(value);
			return color;
		}
		
		override public function fromDecimal(value:uint):void {
			setColorValue(value);
			
			var rgb:RGBColor = RGBColor.fromDecimal(value);
			
			var cmyk:CMYKColor = ColorUtil.RGBToCMYK(rgb.r, rgb.g, rgb.b);
			setProperties(cmyk.c, cmyk.m, cmyk.y, cmyk.k);
		}
		
		override public function toDecimal():uint {
			var rgb:RGBColor = ColorUtil.CMYKToRGB(c, m, y, k);
			return rgb.colorValue;
		}
		
		override public function toString():String {
			if (c == 0 && m == 0 && y == 0) {
				return "[CMYKColor k:"+k+"]";
				
			} else {
				return "[CMYKColor c:"+c+" m:"+m+" y:"+y+" k:"+k+"]";
			}
		}
		
	}
}