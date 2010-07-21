package nl.mediamonkey.color {
	
	import nl.mediamonkey.color.utils.ColorUtil;
	
	public class Color implements IColor {
		
		// ---- getters & setters ----
		
		private var _colorValue:uint;
		
		[Bindable]
		public function get colorValue():uint {
			return _colorValue;
		}
		
		public function set colorValue(value:uint):void {
			if (_colorValue != value) {
				_colorValue = value; // just to be sure not to break the binding
				fromDecimal(value);
			}
		}
		
		public function setColorValue(value:uint):void {
			_colorValue = value;
		}
		
		// ---- conversion methods ----
		
		public function fromDecimal(value:uint):void {
			throw new Error("Class must override fromDecimal method");
		}
		
		public function toDecimal():uint {
			throw new Error("Class must override toDecimal method");
		}
		
		// ---- more conversion methods ----
		
		public function toString():String {
			return "[Color value:"+colorValue+"]";
		}
		
		public function toHexString(prefix:String="#"):String {
			return ColorUtil.toHexString(colorValue, 6, prefix);
		}
		
		public function toRGBColor():RGBColor {
			var color:RGBColor = new RGBColor();
			color.fromDecimal(colorValue);
			return color;
		}
		
		public function toARGBColor():ARGBColor {
			var color:ARGBColor = new ARGBColor();
			color.fromDecimal(colorValue);
			return color;
		}
		
		public function toHexColor():HexColor {
			var color:HexColor = new HexColor();
			color.fromDecimal(colorValue);
			return color;
		}
		
		public function toCMYKColor():CMYKColor {
			var color:CMYKColor = new CMYKColor();
			color.fromDecimal(colorValue);
			return color;
		}
		
		public function toHSVColor():HSVColor {
			var color:HSVColor = new HSVColor();
			color.fromDecimal(colorValue);
			return color;
		}
		
		public function toHSLColor():HSLColor {
			var color:HSLColor = new HSLColor();
			color.fromDecimal(colorValue);
			return color;
		}
		
		public function toXYZColor():XYZColor {
			var color:XYZColor = new XYZColor();
			color.fromDecimal(colorValue);
			return color;
		}
		
		public function toLABColor():LABColor {
			var color:LABColor = new LABColor();
			color.fromDecimal(colorValue);
			return color;
		}
		
		// ---- color manipulation ----
		
		public function tint(color:IColor, ratio:Number = 0.5):void {
			var result:uint = ColorUtil.interpolate(this, color, ratio);
			fromDecimal(result);
		}
		
		public function saturate(saturation:Number):void {
			var result:uint = ColorUtil.saturate(this, saturation);
			fromDecimal(result);
		}
		
		public function lighten(lightness:Number):void {
			var result:uint = ColorUtil.lighten(this, lightness);
			fromDecimal(result);
		}
		
		public function multiply(color:IColor):void {
			var result:uint = ColorUtil.multiply(this, color);
			fromDecimal(result);
		}
		
		public function brighten():void {
			var result:uint = ColorUtil.brighten(this);
			fromDecimal(result);
		}
		
		public function darken():void {
			var result:uint = ColorUtil.darken(this);
			fromDecimal(result);
		}
		
		public function invert():void {
			fromDecimal(0xFFFFFF - colorValue);
		}
		
		public function desaturate():void {
			var result:uint = ColorUtil.desaturate(this);
			fromDecimal(result);
		}
		
	}
}