package nl.mediamonkey.color {
	import nl.mediamonkey.color.utils.ColorUtil;
	
	
	public class LABColor extends Color {
		
		public static const MIN_L	:Number = 0;
		public static const MAX_L	:Number = 100;
		public static const MIN_A	:Number = -128;
		public static const MAX_A	:Number = 127;
		public static const MIN_B	:Number = -128;
		public static const MAX_B	:Number = 127;
		
		// ---- getters & setters ----
		
		private var _l			:Number; // 0 to 100 luminance in percentage, brightness = l/2
		private var _a			:Number; // -128 to 127 value between red and green
		private var _b			:Number; // -128 to 127 value between yellow and blue
		
		public function get l():uint {
			return _l;
		}
		
		public function set l(value:uint):void {
			if (_l != value) {
				setProperties(value, a, b);
				setColorValue(toDecimal());
			}
		}
		
		public function get a():uint {
			return _a;
		}
		
		public function set a(value:uint):void {
			if (_a != value) {
				setProperties(l, value, b);
				setColorValue(toDecimal());
			}
		}
		
		public function get b():uint {
			return _b;
		}
		
		public function set b(value:uint):void {
			if (_b != value) {
				setProperties(l, a, value);
				setColorValue(toDecimal());
			}
		}
		
		// ---- constructor ----
		
		public function LABColor(luminance:uint=0, redGreen:int=0, yellowBlue:int=0) {
			setProperties(luminance, redGreen, yellowBlue);
			setColorValue(toDecimal());
		}
		
		// ---- protected methods ----
		
		protected function setProperties(l:Number, a:Number, b:Number):void {
			_l = Math.max(MIN_L, Math.min(l, MAX_L));
			_a = Math.max(MIN_A, Math.min(a, MAX_A));
			_b = Math.max(MIN_B, Math.min(b, MAX_B));
		}
		
		// ---- conversion methods ----
		
		public static function fromDecimal(value:uint):LABColor {
			var color:LABColor = new LABColor();
			color.fromDecimal(value);
			return color;
		}
		
		override public function fromDecimal(value:uint):void {
			setColorValue(value);
			
			var rgb:RGBColor = RGBColor.fromDecimal(value);
			
			var lab:LABColor = ColorUtil.RGBToLAB(rgb.r, rgb.g, rgb.b);
			_l = lab.l;
			_a = lab.a;
			_b = lab.b;
		}
		
		override public function toDecimal():uint {
			var rgb:RGBColor = ColorUtil.LABToRGB(l, a, b);
			return rgb.colorValue;
		}
		
		override public function toString():String {
			return "[LABColor l:"+l+" a:"+a+" b:"+b+"]";
		}
		
	}
}