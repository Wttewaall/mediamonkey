package nl.mediamonkey.color {
	import nl.mediamonkey.color.utils.ColorUtil;
	
	
	public class HSLColor extends Color {
		
		public static const MIN_H	:Number = 0;
		public static const MAX_H	:Number = 360;
		public static const MIN_S	:Number = 0;
		public static const MAX_S	:Number = 100;
		public static const MIN_L	:Number = 0;
		public static const MAX_L	:Number = 255;
		
		// ---- getters & setters ----
		
		private var _h			:uint; // 0 to 360 hue in degrees
		private var _s			:uint; // 0 to 100 saturation in percentage
		private var _l			:uint; // 0 to 255 lightness
		
		public function get h():uint {
			return _h;
		}
		
		public function set h(value:uint):void {
			if (_h != value) {
				setProperties(value, s, l);
				setColorValue(toDecimal());
			}
		}
		
		public function get s():uint {
			return _s;
		}
		
		public function set s(value:uint):void {
			if (_s != value) {
				setProperties(h, value, l);
				setColorValue(toDecimal());
			}
		}
		
		public function get l():uint {
			return _l;
		}
		
		public function set l(value:uint):void {
			if (_l != value) {
				setProperties(h, s, value);
				setColorValue(toDecimal());
			}
		}
		
		// ---- constructor ----
		
		public function HSLColor(hue:uint=0, saturation:uint=0, lightness:uint=0) {
			setProperties(hue, saturation, lightness);
			setColorValue(toDecimal());
		}
		
		// ---- protected methods ----
		
		protected function setProperties(h:Number, s:Number, l:Number):void {
			_h = Math.max(MIN_H, Math.min(h, MAX_H));
			_s = Math.max(MIN_S, Math.min(s, MAX_S));
			_l = Math.max(MIN_L, Math.min(l, MAX_L));
		}
		
		// ---- conversion methods ----
		
		public static function fromDecimal(value:uint):HSLColor {
			var color:HSLColor = new HSLColor();
			color.fromDecimal(value);
			return color;
		}
		
		override public function fromDecimal(value:uint):void {
			setColorValue(value);
			
			var rgb:RGBColor = RGBColor.fromDecimal(value);
			
			var hsl:HSLColor = ColorUtil.RGBToHSL(rgb.r, rgb.g, rgb.b);
			_h = hsl.h;
			_s = hsl.s;
			_l = hsl.l;
		}
		
		override public function toDecimal():uint {
			var rgb:RGBColor = ColorUtil.HSLToRGB(h, s, l);
			return rgb.colorValue;
		}
		
		override public function toString():String {
			return "[HSLColor h:"+h+" s:"+s+" l:"+l+"]";
		}
		
	}
}