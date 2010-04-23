package nl.mediamonkey.color {
	import nl.mediamonkey.color.utils.ColorUtil;
	
	
	public class HSVColor extends Color {
		
		private var _H			:uint; // 0 to 360 hue in degrees
		private var _S			:uint; // 0 to 100 saturation in percentage
		private var _V			:uint; // 0 to 100 lightness/value/tone in percentage
		
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
		
		public function get V():uint {
			return _V;
		}
		
		public function set V(value:uint):void {
			if (_V != value) {
				_V = Math.max(0, Math.min(value, 100));
				setColorValue(toDecimal());
			}
		}
		
		public function HSVColor(H:uint=0, S:uint=0, V:uint=0) {
			_H = Math.max(0, Math.min(H, 360));
			_S = Math.max(0, Math.min(S, 100));
			_V = Math.max(0, Math.min(V, 100));
			setColorValue(toDecimal());
		}
		
		// ---- conversion methods ----
		
		override public function fromDecimal(value:uint):IColor {
			setColorValue(value);
			
			var rgb:RGBColor = new RGBColor();
			rgb.fromDecimal(value);
			
			var hsv:HSVColor = ColorUtil.RGBToHSV(rgb.R, rgb.G, rgb.B);
			_H = hsv.H;
			_S = hsv.S;
			_V = hsv.V;
			
			return hsv;
		}
		
		override public function toDecimal():uint {
			var rgb:RGBColor = ColorUtil.HSVToRGB(H, S, V);
			return rgb.colorValue;
		}
		
		override public function toString():String {
			return "[HSVColor H:"+H+" S:"+S+" V:"+V+"]";
		}
		
	}
}