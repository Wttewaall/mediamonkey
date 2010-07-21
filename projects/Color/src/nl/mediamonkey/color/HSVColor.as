package nl.mediamonkey.color {
	import nl.mediamonkey.color.utils.ColorUtil;
	
	
	public class HSVColor extends Color {
		
		public static const MIN_H	:Number = 0;
		public static const MAX_H	:Number = 360;
		public static const MIN_S	:Number = 0;
		public static const MAX_S	:Number = 100;
		public static const MIN_V	:Number = 0;
		public static const MAX_V	:Number = 100;
		
		// ---- getters & setters ----
		
		private var _h			:uint; // 0 to 360 hue in degrees
		private var _s			:uint; // 0 to 100 saturation in percentage
		private var _v			:uint; // 0 to 100 lightness/value/tone in percentage
		
		public function get h():uint {
			return _h;
		}
		
		public function set h(value:uint):void {
			if (_h != value) {
				setProperties(value, s, v);
				setColorValue(toDecimal());
			}
		}
		
		public function get s():uint {
			return _s;
		}
		
		public function set s(value:uint):void {
			if (_s != value) {
				setProperties(h, value, v);
				setColorValue(toDecimal());
			}
		}
		
		public function get v():uint {
			return _v;
		}
		
		public function set v(value:uint):void {
			if (_v != value) {
				setProperties(h, s, value);
				setColorValue(toDecimal());
			}
		}
		
		// ---- constructor ----
		
		public function HSVColor(hue:uint=0, saturation:uint=0, value:uint=0) {
			setProperties(hue, saturation, value);
			setColorValue(toDecimal());
		}
		
		// ---- protected methods ----
		
		protected function setProperties(h:Number, s:Number, v:Number):void {
			_h = Math.max(MIN_H, Math.min(h, MAX_H));
			_s = Math.max(MIN_S, Math.min(s, MAX_S));
			_v = Math.max(MIN_V, Math.min(v, MAX_V));
		}
		
		// ---- conversion methods ----
		
		public static function fromDecimal(value:uint):HSVColor {
			var color:HSVColor = new HSVColor();
			color.fromDecimal(value);
			return color;
		}
		
		override public function fromDecimal(value:uint):void {
			setColorValue(value);
			
			var rgb:RGBColor = RGBColor.fromDecimal(value);
			
			var hsv:HSVColor = ColorUtil.RGBToHSV(rgb.r, rgb.g, rgb.b);
			_h = hsv.h;
			_s = hsv.s;
			_v = hsv.v;
		}
		
		override public function toDecimal():uint {
			var rgb:RGBColor = ColorUtil.HSVToRGB(h, s, v);
			return rgb.colorValue;
		}
		
		override public function toString():String {
			return "[HSVColor h:"+h+" s:"+s+" v:"+v+"]";
		}
		
	}
}