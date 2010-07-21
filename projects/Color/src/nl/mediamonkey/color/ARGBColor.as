package nl.mediamonkey.color {
	
	import nl.mediamonkey.color.utils.ColorUtil;
	
	public class ARGBColor extends RGBColor {
		
		// ---- getters & setters ----
		
		private var _a:uint; // 0 to 255
		
		[Bindable]
		public function get a():uint {
			return _a;
		}
		
		public function set a(value:uint):void {
			if (_a != value) setAlpha(value);
		}
		
		// ---- constructor ----
		
		public function ARGBColor(alpha:uint=255, red:uint=0, green:uint=0, blue:uint=0) {
			super(red, green, blue);
			setAlpha(alpha);
		}
		
		// ---- protected methods ----
		
		protected function setAlpha(a:uint, invalidate:Boolean=true):void {
			_a = Math.max(MIN_VALUE, Math.min(a, MAX_VALUE));
			
			if (invalidate) invalidateColorValue();
		}
		
		// ---- conversion methods ----
		
		public static function fromDecimal(value:uint):ARGBColor {
			var color:ARGBColor = new ARGBColor();
			color.fromDecimal(value);
			return color;
		}
		
		override public function fromDecimal(value:uint):void {
			if (value < 0 || value > 0xFFFFFFFF)
				throw new ArgumentError("invalid value, input must be a value between 0x00000000 and 0xFFFFFFFF");
			
			setColorValue(value);
			setProperties(value >> 16 & 0xFF, value >> 8 & 0xFF, value & 0xFF, false);
			setAlpha(value >> 24 & 0xFF, false);
		}
		
		override public function toDecimal():uint {
			return a << 24 | r << 16 | g << 8 | b;
		}
		
		override public function toString():String {
			return "[ARGBColor a:"+a+" r:"+r+" g:"+g+" b:"+b+"]";
		}
		
		override public function invert():void {
			fromDecimal(0xFFFFFFFF - colorValue);
		}
		
		/**
		 * returns String with mask: #AARRGGBB
		 */
		override public function toHexString(prefix:String="#"):String {
			return ColorUtil.toHexString(colorValue, 8, prefix);
		}
		
	}
}