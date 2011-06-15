package nl.mediamonkey.color {
	
	import nl.mediamonkey.color.utils.ColorUtil;
	
	public class XYZColor extends Color {
		
		public static const MIN_VALUE	:Number = 0;
		public static const MAX_X		:Number = 95.047;
		public static const MAX_Y		:Number = 100.000;
		public static const MAX_Z		:Number = 108.883;
		
		// ---- getters & setters ----
		
		private var _x			:Number; // 0 to 95.047 Observer= 2°, Illuminant= D65
		private var _y			:Number; // 0 to 100.000
		private var _z			:Number; // 0 to 108.883
		
		public function get x():uint {
			return _x;
		}
		
		public function set x(value:uint):void {
			if (_x != value) {
				setProperties(value, y, z);
				setColorValue(toDecimal());
			}
		}
		
		public function get y():uint {
			return _y;
		}
		
		public function set y(value:uint):void {
			if (_y != value) {
				setProperties(x, value, z);
				setColorValue(toDecimal());
			}
		}
		
		public function get z():uint {
			return _z;
		}
		
		public function set z(value:uint):void {
			if (_z != value) {
				setProperties(x, y, value);
				setColorValue(toDecimal());
			}
		}
		
		// ---- constructor ----
		
		public function XYZColor(x:Number=0, y:Number=0, z:Number=0) {
			setProperties(x, y, z);
			setColorValue(toDecimal());
		}
		
		// ---- protected methods ----
		
		protected function setProperties(x:Number, y:Number, z:Number):void {
			_x = Math.max(MIN_VALUE, Math.min(x, MAX_X));
			_y = Math.max(MIN_VALUE, Math.min(y, MAX_Y));
			_z = Math.max(MIN_VALUE, Math.min(z, MAX_Z));
		}
		
		// ---- conversion methods ----
		
		public static function fromDecimal(value:uint):XYZColor {
			var color:XYZColor = new XYZColor();
			color.fromDecimal(value);
			return color;
		}
		
		override public function fromDecimal(value:uint):void {
			setColorValue(value);
			
			var rgb:RGBColor = RGBColor.fromDecimal(value);
			
			var xyz:XYZColor = ColorUtil.RGBToXYZ(rgb.r, rgb.g, rgb.b);
			_x = xyz.x;
			_y = xyz.y;
			_z = xyz.z;
		}
		
		override public function toDecimal():uint {
			var rgb:RGBColor = ColorUtil.XYZToRGB(x, y, z);
			return rgb.colorValue;
		}
		
		override public function toString():String {
			return "[XYZColor x:"+x+" y:"+y+" z:"+z+"]";
		}
		
	}
}