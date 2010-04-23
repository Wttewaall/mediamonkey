package nl.mediamonkey.color {
	import nl.mediamonkey.color.utils.ColorUtil;
	
	
	public class LABColor extends Color {
		
		private var _L			:Number; // 0 to 100 luminance in percentage, brghtness = l/2
		private var _A			:Number; // -128 to 127 value between red and green
		private var _B			:Number; // -128 to 127 value between yellow and blue
		
		public function get L():uint {
			return _L;
		}
		
		public function set L(value:uint):void {
			if (_L != value) {
				_L = Math.max(0, Math.min(value, 100));
				setColorValue(toDecimal());
			}
		}
		
		public function get A():uint {
			return _A;
		}
		
		public function set A(value:uint):void {
			if (_A != value) {
				_A = Math.max(-128, Math.min(value, 127));
				setColorValue(toDecimal());
			}
		}
		
		public function get B():uint {
			return _B;
		}
		
		public function set B(value:uint):void {
			if (_B != value) {
				_B = Math.max(-128, Math.min(value, 127));
				setColorValue(toDecimal());
			}
		}
		
		public function LABColor(luminance:uint=0, redGreen:int=0, yellowBlue:int=0) {
			_L = Math.max(0, Math.min(luminance, 100));
			_A = Math.max(-128, Math.min(redGreen, 127));
			_B = Math.max(-128, Math.min(yellowBlue, 127));
			setColorValue(toDecimal());
		}
		
		// ---- conversion methods ----
		
		override public function fromDecimal(value:uint):IColor {
			setColorValue(value);
			
			var rgb:RGBColor = new RGBColor();
			rgb.fromDecimal(value);
			
			var lab:LABColor = ColorUtil.RGBToLAB(rgb.R, rgb.G, rgb.B);
			_L = lab.L;
			_A = lab.A;
			_B = lab.B;
			
			return lab;
		}
		
		override public function toDecimal():uint {
			var rgb:RGBColor = ColorUtil.LABToRGB(L, A, B);
			return rgb.colorValue;
		}
		
		override public function toString():String {
			return "[LABColor L:"+L+" A:"+A+" B:"+B+"]";
		}
		
	}
}