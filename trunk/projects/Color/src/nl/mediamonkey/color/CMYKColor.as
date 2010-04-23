package nl.mediamonkey.color {
	import nl.mediamonkey.color.utils.ColorUtil;
	
	
	public class CMYKColor extends Color {
		
		// ---- getters & setters ----
		
		private var _C			:Number;		// 0 to 100 cyan in percentage
		private var _M			:Number;		// 0 to 100 magenta in percentage
		private var _Y			:Number;		// 0 to 100 yellow in percentage
		private var _K			:Number;		// 0 to 100 key (black) in percentage
		
		public function get C():Number {
			return _C;
		}
		
		public function set C(value:Number):void {
			if (_C != value) {
				_C = value;
				setColorValue(toDecimal());
			}
		}
		
		public function get M():Number {
			return _M;
		}
		
		public function set M(value:Number):void {
			if (_M != value) {
				_M = value;
				setColorValue(toDecimal());
			}
		}
		
		public function get Y():Number {
			return _Y;
		}
		
		public function set Y(value:Number):void {
			if (_Y != value) {
				_Y = value;
				setColorValue(toDecimal());
			}
		}
		
		public function get K():Number {
			return _K;
		}
		
		public function set K(value:Number):void {
			if (_K != value) {
				_K = value;
				setColorValue(toDecimal());
			}
		}
		
		// ---- constructor ----
		
		public function CMYKColor(C:Number=0, M:Number=0, Y:Number=0, K:Number=0) {
			_C = Math.max(0, Math.min(C, 100));
			_M = Math.max(0, Math.min(M, 100));
			_Y = Math.max(0, Math.min(Y, 100));
			_K = Math.max(0, Math.min(K, 100));
			setColorValue(toDecimal());
		}
		
		// ---- conversion methods ----
		
		override public function fromDecimal(value:uint):IColor {
			setColorValue(value);
			
			var rgb:RGBColor = new RGBColor();
			rgb.fromDecimal(value);
			
			var cmyk:CMYKColor = ColorUtil.RGBToCMYK(rgb.R, rgb.G, rgb.B);
			_C = cmyk.C;
			_M = cmyk.M;
			_Y = cmyk.Y;
			_K = cmyk.K;
			
			return cmyk;
		}
		
		override public function toDecimal():uint {
			var rgb:RGBColor = ColorUtil.CMYKToRGB(C, M, Y, K);
			return rgb.colorValue;
		}
		
		override public function toString():String {
			if (C == 0 && M == 0 && Y == 0) {
				return "[CMYKColor K:"+K+"]";
				
			} else {
				return "[CMYKColor C:"+C+" M:"+M+" Y:"+Y+" K:"+K+"]";
			}
		}
		
	}
}