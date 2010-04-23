package nl.mediamonkey.color {
	import nl.mediamonkey.color.utils.ColorUtil;
	
	
	public class HSLColor extends Color {
		
		private var _H			:uint; // 0 to 360 hue in degrees
		private var _S			:uint; // 0 to 100 saturation in percentage
		private var _L			:uint; // 0 to 255 lightness
		
		public function get H():uint {
			return _H;
		}
		
		public function set H(value:uint):void {
			if (_H != value) {
				_H = Math.max(0, Math.min(value, 360));
				setColorValue(toDecimal());
			}
		}
		
		public function get S():uint {
			return _S;
		}
		
		public function set S(value:uint):void {
			if (_S != value) {
				_S = Math.max(0, Math.min(value, 100));
				setColorValue(toDecimal());
			}
		}
		
		public function get L():uint {
			return _L;
		}
		
		public function set L(value:uint):void {
			if (_L != value) {
				_L = Math.max(0, Math.min(value, 255));
				setColorValue(toDecimal());
			}
		}
		
		public function HSLColor(H:uint=0, S:uint=0, L:uint=0) {
			_H = Math.max(0, Math.min(H, 360));
			_S = Math.max(0, Math.min(S, 100));
			_L = Math.max(0, Math.min(L, 255));
			setColorValue(toDecimal());
		}
		
		// ---- conversion methods ----
		
		override public function fromDecimal(value:uint):IColor {
			setColorValue(value);
			
			var rgb:RGBColor = new RGBColor();
			rgb.fromDecimal(value);
			
			var hsl:HSLColor = ColorUtil.RGBToHSL(rgb.R, rgb.G, rgb.B);
			_H = hsl.H;
			_S = hsl.S;
			_L = hsl.L;
			
			return hsl;
		}
		
		override public function toDecimal():uint {
			var rgb:RGBColor = ColorUtil.HSLToRGB(H, S, L);
			return rgb.colorValue;
		}
		
		override public function toString():String {
			return "[HSLColor H:"+H+" S:"+S+" L:"+L+"]";
		}
		
	}
}