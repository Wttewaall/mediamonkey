package nl.mediamonkey.color {
	
	import nl.mediamonkey.color.utils.ColorUtil;
	
	public class XYZColor extends Color {
		
		private var _X			:Number; // 0 to 95.047 Observer= 2°, Illuminant= D65
		private var _Y			:Number; // 0 to 100.000
		private var _Z			:Number; // 0 to 108.883
		
		public function get X():uint {
			return _X;
		}
		
		public function set X(value:uint):void {
			if (_X != value) {
				_X = Math.max(0, Math.min(value, 95.047));
				setColorValue(toDecimal());
			}
		}
		
		public function get Y():uint {
			return _Y;
		}
		
		public function set Y(value:uint):void {
			if (_Y != value) {
				_Y = Math.max(0, Math.min(value, 100.000));
				setColorValue(toDecimal());
			}
		}
		
		public function get Z():uint {
			return _Z;
		}
		
		public function set Z(value:uint):void {
			if (_Z != value) {
				_Z = Math.max(0, Math.min(value, 108.883));
				setColorValue(toDecimal());
			}
		}
		
		public function XYZColor(X:Number=0, Y:Number=0, Z:Number=0) {
			_X = Math.max(0, Math.min(X, 95.047));
			_Y = Math.max(0, Math.min(Y, 100.000));
			_Z = Math.max(0, Math.min(Z, 108.883));
			setColorValue(toDecimal());
		}
		
		// ---- conversion methods ----
		
		override public function fromDecimal(value:uint):IColor {
			setColorValue(value);
			
			var rgb:RGBColor = new RGBColor();
			rgb.fromDecimal(value);
			
			var xyz:XYZColor = ColorUtil.RGBToXYZ(rgb.R, rgb.G, rgb.B);
			_X = xyz.X;
			_Y = xyz.Y;
			_Z = xyz.Z;
			
			return xyz;
		}
		
		override public function toDecimal():uint {
			var rgb:RGBColor = ColorUtil.XYZToRGB(X, Y, Z);
			return rgb.colorValue;
		}
		
		override public function toString():String {
			return "[XYZColor X:"+X+" Y:"+Y+" Z:"+Z+"]";
		}
		
	}
}